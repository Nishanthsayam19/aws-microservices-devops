const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        message: "Welcome to Product Service"
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "success",
        service: "product-service"
    });
});

app.get("/products", (req, res) => {
    res.json([
        { id: 1, name: "Laptop", price: 50000 },
        { id: 2, name: "Mobile", price: 20000 }
    ]);
});

const PORT = 3002;

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Product Service running on port ${PORT}`);
});
