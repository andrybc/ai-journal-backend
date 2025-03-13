const express = require("express");
const router = express.Router();
const notebookController = require("../controllers/notebookController");

router.post("/create-notebook", notebookController.createNotebook);

router.put("/update-notebook", notebookController.updateNotebook);

router.delete("/delete-notebook", notebookController.deleteNotebook);

router.get("/read-notebook", notebookController.readNotebook);

module.exports = router;
