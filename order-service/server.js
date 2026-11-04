const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        message: "Welcome to Order Service"
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "success",
        service: "order-service"
    });
});

app.get("/orders", (req, res) => {
    res.json([
        { id: 101, product: "Laptop", quantity: 1 },
        { id: 102, product: "Mobile", quantity: 2 }
    ]);
});

const PORT = 3003;

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Order Service running on port ${PORT}`);
});
