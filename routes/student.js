const express = require("express");
const auth = require("../middleware/auth");
const studentOnly = require("../middleware/studentOnly");
const Outpass = require("../models/Outpass");
const staffOnly = require("../middleware/staffOnly");
const User = require("../models/User");
const moment = require("moment-timezone");
const router = express.Router();
router.post("/request", auth, studentOnly, async (req, res) => {
  try {
    let { reason, outTime, inTime } = req.body;

    if (!reason || !outTime || !inTime) {
      return res.status(400).json({ msg: "All fields required" });
    }

    // Parse dates safely (assume frontend sends ISO string in UTC)
    const outDate = new Date(outTime);
    const inDate = new Date(inTime);

    if (isNaN(outDate) || isNaN(inDate)) {
      return res.status(400).json({ msg: "Invalid date format" });
    }

    // Ensure student doesn't have pending outpass
    const existing = await Outpass.findOne({
      student: req.user.id,
      status: "pending"
    });

    if (existing) {
      return res.status(400).json({ msg: "You already have a pending outpass" });
    }

    // Save in MongoDB (stored in UTC automatically)
    const outpass = new Outpass({
      student: req.user.id,
      reason,
      outTime: outDate,
      inTime: inDate
    });

    await outpass.save();

    res.json({ msg: "Outpass requested successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});



router.get("/my", auth, studentOnly, async (req, res) => {
  try {
    const outpasses = await Outpass.find({ student: req.user.id })
      .sort({ createdAt: -1 })
      .populate("staff", "name");

    // Simplify the response: Just send raw objects. 
    // Express automatically converts MongoDB Dates to ISO Strings.
    res.json(outpasses); 
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
})


router.delete("/cancel/:id", auth, studentOnly, async (req, res) => {
  try {
    const outpass = await Outpass.findById(req.params.id);

    if (!outpass) {
      return res.status(404).json({ msg: "Outpass not found" });
    }

    // ownership check
    if (outpass.student.toString() !== req.user.id) {
      return res.status(403).json({ msg: "Unauthorized" });
    }

    if (outpass.status !== "pending") {
      return res.status(400).json({
        msg: "Only pending outpass can be cancelled"
      });
    }

    await outpass.deleteOne();
    res.json({ msg: "Outpass cancelled successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



router.get("/me", auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select("name email phone role");

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



router.put("/reached/:id", auth, studentOnly, async (req, res) => {
  try {
    const outpass = await Outpass.findById(req.params.id);

    if (!outpass) {
      return res.status(404).json({ msg: "Outpass not found" });
    }

    if (outpass.student.toString() !== req.user.id) {
      return res.status(403).json({ msg: "Unauthorized" });
    }

    if (outpass.status !== "approved") {
      return res.status(400).json({ msg: "Outpass not approved" });
    }

    if (outpass.reached) {
      return res.status(400).json({ msg: "Already marked as reached" });
    }

    const now = new Date();

    outpass.reached = true;
    outpass.actualInTime = now;


    if (now > outpass.inTime) {
      const diff = Math.floor(
        (now - outpass.inTime) / (1000 * 60)
      );
      outpass.delayMinutes = diff;
    }

    await outpass.save();

    res.json({ msg: "Return marked successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
  

  module.exports = router;