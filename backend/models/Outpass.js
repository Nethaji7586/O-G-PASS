const mongoose = require("mongoose");

const OutpassSchema = new mongoose.Schema(
  {
    student: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    reason: {
      type: String,
      required: true,
      trim: true
    },

    outTime: {
      type: Date,
      required: true
    },

    inTime: {
      type: Date,
      required: true
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending"
    },
    staff: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    },

    actionTime: {
      type: Date
    },


    reached: {
      type: Boolean,
      default: false
    },

    
    actualInTime: {
      type: Date
    },

    delayMinutes: {
      type: Number,
      default: 0
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Outpass", OutpassSchema);
