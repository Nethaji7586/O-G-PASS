module.exports = function (req, res, next) {
  if (req.user.role !== "student") {
    return res.status(403).json({ msg: "Student access only" });
  }
  next();
};
