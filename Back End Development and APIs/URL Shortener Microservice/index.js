require("dotenv").config();
const express = require("express");
const cors = require("cors");
const app = express();
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const dns = require("dns");
const { json } = require("body-parser");
const dnsPromises = dns.promises;
const URL = require("url");

// Basic Configuration
const port = process.env.PORT || 3000;

app.use(cors());

app.use("/public", express.static(`${process.cwd()}/public`));

app.get("/", function (req, res) {
    res.sendFile(process.cwd() + "/views/index.html");
});

// DB initialization
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });

// =============
// schema:  the structure of the document, default values, validators
// =============
// create schema url-shortener (mongodb)
let urlShortenerSchema = new mongoose.Schema({
    // get new ID by count total number of url and plus 1
    original_url: {
        type: String,
        required: true,
        unique: true,
    },
    short_url: {
        type: Number,
        required: true,
        unique: true,
    },
});

// create model url-shortener (an interface to crea)
// =============
// model: an interface to the database for creating, querying, updating, deleting records, etc.
// =============
let URLShortener = mongoose.model("URLShortener", urlShortenerSchema);
// END of DB initialization

// URL parser (parse incoming data for POST request)
let encoded_url = bodyParser.urlencoded({ extended: false });
app.use(encoded_url, function (req, res, next) {
    next();
});

let checkValidURL = async (url) => {
    const options = {
        verbatim: false,
        hints: dns.ADDRCONFIG,
    };
    let urlObject = URL.parse(url, true);
    let urlProtocol = urlObject.protocol;
    if (urlProtocol != "http:" && urlProtocol != "https:") {
        return { err: true, message: "invalid url" };
    }

    // check valid hostname
    let hostname = urlObject.hostname;
    try {
        await dnsPromises.lookup(hostname, options);
        return { err: false };
    } catch (err) {
        return { err: true, message: "Invalid Hostname" };
    }
};

// insert url mapping to mongodb
let getTotalURL = async () => {
    let total = await URLShortener.estimatedDocumentCount();
    return total;
};

let checkURLExist = async (url) => {
    let exist_url = await URLShortener.findOne({ original_url: url }).exec();
    return exist_url;
};

let getOriginalURL = async (short_url) => {
    let urlValue = await URLShortener.findOne({ short_url }).exec();
    return urlValue.original_url;
};

let insertURL = async (url) => {
    let totalURL = await getTotalURL();
    let newURLId = totalURL + 1;
    try {
        let newUrl = new URLShortener({
            original_url: url,
            short_url: newURLId,
        });
        newUrl = await newUrl.save();
        return newUrl;
    } catch (err) {
        return false;
    }

    return newURLId;
};

app.post("/api/shorturl", async function (req, res) {
    let url = req.body.url;
    const options = {
        family: 4,
    };
    let checkResult = await checkValidURL(url);
    if (checkResult.err) {
        res.json({ error: checkResult.message });
    } else {
        let exist_url = await checkURLExist(url);

        if (!exist_url) {
            exist_url = await insertURL(url);
        }
        res.json({ original_url: exist_url.original_url, short_url: exist_url.short_url });
    }
});

app.get("/api/shorturl/:id?", async function (req, res) {
    let id = req.params.id;
    if (!id) {
        res.send("Not Found");
    } else {
        try {
            let original_url = await getOriginalURL(id);
            res.redirect(original_url);
        } catch (err) {
            res.send("Not Found");
        }
    }
});

app.listen(port, function () {
    console.log(`Listening on port ${port}`);
});
