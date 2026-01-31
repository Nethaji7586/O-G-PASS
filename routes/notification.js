const express = require("express");
const auth = require("../middleware/auth");
const staffOnly = require("../middleware/staffOnly");
const Notification = require("../models/Notification");

const router = express.Router();
router.post("/send", auth, staffOnly, async (req, res) => {
  try {
    const { title, message } = req.body;

    if (!title || !message) {
      return res.status(400).json({ msg: "Title and message required" });
    }

    const expiresAt = new Date(Date.now() + 12 * 60 * 60 * 1000);

    const notification = new Notification({
      title,
      message,
      createdBy: req.user.id,
      expiresAt
    });

    await notification.save();

    res.json({
      msg: "Notification sent successfully",
      notification
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.put("/edit/:id", auth, staffOnly, async (req, res) => {
  try {
    const { title, message } = req.body;

    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({ msg: "Notification not found" });
    }

    if (notification.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ msg: "Unauthorized" });
    }

    if (notification.expiresAt < new Date()) {
      return res.status(400).json({ msg: "Notification already expired" });
    }

    if (title) notification.title = title;
    if (message) notification.message = message;

    await notification.save();

    res.json({
      msg: "Notification updated successfully",
      notification
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/staff/my", auth, staffOnly, async (req, res) => {
  try {
    const notifications = await Notification.find({
      createdBy: req.user.id
    }).sort({ createdAt: -1 });

    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get("/active", auth, async (req, res) => {
  try {
    const now = new Date();

    const notifications = await Notification.find({
      expiresAt: { $gt: now }
    }).sort({ createdAt: -1 });

    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete("/delete/:id", auth, staffOnly, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({ msg: "Notification not found" });
    }

    if (notification.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ msg: "Unauthorized" });
    }

    await notification.deleteOne();

    res.json({ msg: "Notification deleted successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
