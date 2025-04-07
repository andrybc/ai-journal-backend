const express = require("express");
const router = express.Router();
const notebookController = require("../controllers/notebookController");

router.post("/create-notebook", notebookController.createNotebook);

router.put("/update-notebook/:notebookId", notebookController.updateNotebook);

router.delete(
  "/delete-notebook/:notebookId",
  notebookController.deleteNotebook,
);

router.get("/read-notebook/:notebookId", notebookController.readNotebook);

router.get("/search", notebookController.searchNotebooks);
router.get("/all/:userId", notebookController.getAllNotebooks);
router.get("/:userId/:notebookId", notebookController.getNotebookById);

module.exports = router;
