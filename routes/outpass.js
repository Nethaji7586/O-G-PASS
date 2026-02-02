const express = require("express");
const auth = require("../middleware/auth");
const staffOnly = require("../middleware/staffOnly");
const Outpass = require("../models/Outpass");

const router = express.Router();

router.get("/pending", auth, staffOnly, async (req, res) => {
  try {
    const outpasses = await Outpass.find({ status: "pending" })
      .populate("student", "name email")
      .sort({ createdAt: -1 });
   res.json(outpasses);
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

router.put("/approve-all", auth, staffOnly, async (req, res) => {
  try {
    const result = await Outpass.updateMany(
      { status: "pending" },
      {
        $set: {
          status: "approved",
          staff: req.user.id,
          actionTime: new Date()
        }
      }
    );

    res.json({
      msg: "All pending outpasses approved successfully",
      approvedCount: result.modifiedCount
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put("/reject-all", auth, staffOnly, async (req, res) => {
  try {
    const result = await Outpass.updateMany(
      { status: "pending" },
      {
        $set: {
          status: "rejected",
          staff: req.user.id,
          actionTime: new Date()
        }
      }
    );

    res.json({
      msg: "All pending outpasses rejected successfully",
      rejectedCount: result.modifiedCount
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Get all students' name and email
router.get("/students", auth, staffOnly, async (req, res) => {
  try {
    const students = await Outpass.find()
      .populate("student", "name email phone")
      .select("student");

    const uniqueStudents = [];
    const studentIds = new Set();

    students.forEach(op => {
      if (op.student && !studentIds.has(op.student._id.toString())) {
        studentIds.add(op.student._id.toString());

        uniqueStudents.push({
          _id: op.student._id,
          name: op.student.name,
          email: op.student.email,
          phone: op.student.phone || null
        });
      }
    });

    res.json(uniqueStudents);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



// Get all reached students with actualInTime
router.get("/delay", auth, staffOnly, async (req, res) => {
  try {
    const reachedOutpasses = await Outpass.find({ reached: true })
      .populate("student", "name email phone")
      .sort({ actualInTime: -1 });

    const result = reachedOutpasses.map(op => ({
      outpassId: op._id,
      studentId: op.student?._id,
      name: op.student?.name,
      email: op.student?.email,
      phone: op.student?.phone || null,
      reason: op.reason,
      outTime: op.outTime,
      inTime: op.inTime,
      actualInTime: op.actualInTime,
      delayMinutes: op.delayMinutes,
      status: op.status
    }));

    res.json(result);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});




 module.exports = router;
