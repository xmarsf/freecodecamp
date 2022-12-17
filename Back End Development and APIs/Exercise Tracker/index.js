const express = require("express");
const app = express();
const cors = require("cors");

const mongoose = require("mongoose");
const bodyParser = require("body-parser");

require("dotenv").config();

app.use(cors());
app.use(express.static("public"));
app.get("/", (req, res) => {
    res.sendFile(__dirname + "/views/index.html");
});

let encoded_url = bodyParser.urlencoded({ extended: false });
app.use(encoded_url, function (req, res, next) {
    next();
});

const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });

let userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
    },
});

let exerciseSchema = new mongoose.Schema({
    username: String,
    description: String,
    duration: Number,
    date: String,
});

let logSchema = new mongoose.Schema({
    username: String,
});

let User = mongoose.model("User", userSchema);
let Exercise = mongoose.model("Exercise", exerciseSchema);

app.post("/api/users", async function (req, res) {
    let username = req.body.username;
    if (!username) {
        res.json({ error: "missing username" });
    } else {
        try {
            let _id;
            let existUser = await User.findOne({ username }).exec();
            if (existUser) {
                _id = existUser._id;
            } else {
                let newUser = new User({ username });
                newUser = await newUser.save();
                _id = newUser._id;
            }
            res.json({ username, _id });
        } catch (err) {
            res.json({ error: err.toString() });
        }
    }
});

app.get("/api/users", async function (req, res) {
    try {
        let allUsers = await User.find({});
        res.send(allUsers);
    } catch (err) {
        console.log(err);
        res.send([]);
    }
});

const listener = app.listen(process.env.PORT || 3000, () => {
    console.log("Your app is listening on port " + listener.address().port);
});
