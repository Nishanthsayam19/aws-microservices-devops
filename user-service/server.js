const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        message: "Welcome to User Service"
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "success",
        service: "user-service"
    });
});

app.get("/users", (req, res) => {
    res.json([
        { id: 1, name: "Nishanth" },
        { id: 2, name: "Rahul" }
    ]);
});

const PORT = 3001;

app.listen(PORT, "0.0.0.0", () => {
    console.log(`User Service running on port ${PORT}`);
});
