-- USERS: Nhân viên, admin
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CATEGORIES: Danh mục món ăn
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- DISHES: Món ăn
CREATE TABLE dishes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    category_id INTEGER REFERENCES categories(id),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ORDERS: Đơn hàng
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    table_number INTEGER,
    total_amount NUMERIC(10, 2),
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, canceled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ORDER ITEMS: Món trong đơn hàng
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    dish_id INTEGER REFERENCES dishes(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    price NUMERIC(10, 2) NOT NULL
);

-- INVENTORY: Nguyên liệu
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    unit VARCHAR(20),
    min_quantity INTEGER DEFAULT 5,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INVENTORY LOGS: Nhập kho, ghi chú
CREATE TABLE inventory_logs (
    id SERIAL PRIMARY KEY,
    inventory_id INTEGER REFERENCES inventory(id),
    quantity_added INTEGER NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DISH INGREDIENTS: Món ăn liên kết nguyên liệu
CREATE TABLE dish_ingredients (
    id SERIAL PRIMARY KEY,
    dish_id INTEGER REFERENCES dishes(id),
    inventory_id INTEGER REFERENCES inventory(id),
    quantity_required INTEGER NOT NULL
);

-- RESERVATIONS: Đặt bàn
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    phone_number VARCHAR(20),
    number_of_guests INTEGER,
    reservation_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'booked', -- booked, canceled, done
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
