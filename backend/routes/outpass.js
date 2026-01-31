const express = require("express");
const auth = require("../middleware/auth");
const staffOnly = require("../middleware/staffOnly");
const Outpass = require("../models/Outpass");

const router = express.Router();

router.get("/pending", auth, staffOnly, async (req, res) => {
  try {
    const requests = await Outpass.find({ status: "pending" })
      .populate("student", "name email");

    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.put("/approve/:id", auth, staffOnly, async (req, res) => {
  try {
    const outpass = await Outpass.findById(req.params.id);

    if (!outpass) {
      return res.status(404).json({ msg: "Outpass not found" });
    }

    if (outpass.status !== "pending") {
      return res.status(400).json({ msg: "Already processed" });
    }

    outpass.status = "approved";
    outpass.staff = req.user.id;
    outpass.actionTime = new Date();

    await outpass.save();

    res.json({ msg: "Outpass approved successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.put("/reject/:id", auth, staffOnly, async (req, res) => {
  try {
    const outpass = await Outpass.findById(req.params.id);

    if (!outpass) {
      return res.status(404).json({ msg: "Outpass not found" });
    }

    if (outpass.status !== "pending") {
      return res.status(400).json({ msg: "Already processed" });
    }

    outpass.status = "rejected";
    outpass.staff = req.user.id;
    outpass.actionTime = new Date();

    await outpass.save();

    res.json({ msg: "Outpass rejected successfully" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get("/staff/count", auth, staffOnly, async (req, res) => {
  try {
    const count = await Outpass.countDocuments({
      status: "pending"
    });

    res.json({ pendingCount: count });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

 module.exports = router;