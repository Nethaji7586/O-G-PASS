const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const auth = require("../middleware/auth");
const router = express.Router();

router.post("/register", async (req, res) => {
  const { name, email, password, role } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    user = new User({
      name,
      email,
      password: hashedPassword,
      role  
    });

    await user.save();
    res.json({ msg: "User registered successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.put("/add-phone", auth, async (req, res) => {
  const { phone } = req.body;

  if (!phone) {
    return res.status(400).json({ msg: "Phone number is required" });
  }

  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // 🔒 one-time only check
    if (user.phone) {
      return res.status(400).json({
        msg: "Phone number already added. You cannot change it."
      });
    }

    user.phone = phone;
    await user.save();

    res.json({
      msg: "Phone number added successfully",
      phone: user.phone
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.json({
      token,
      role: user.role,
      name: user.name
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



router.get("/student", auth, (req, res) => {
  if (req.user.role !== "student") {
    return res.status(403).json({ msg: "Access denied" });
  }
  res.json({ msg: "Welcome Student" });
});


router.get("/staff", auth, (req, res) => {
  if (req.user.role !== "staff") {
    return res.status(403).json({ msg: "Access denied" });
  }
  res.json({ msg: "Welcome Staff" });
});


module.exports = router;
