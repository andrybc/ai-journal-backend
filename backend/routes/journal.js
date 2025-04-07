const express = require("express");
const router = express.Router();
const notebookController = require("../controllers/notebookController");
const authenticateToken = require("../middleware/authenticateToken");

router.post(
  "/create-notebook",
  authenticateToken,
  notebookController.createNotebook,
);
router.put(
  "/update-notebook/:notebookId",
  authenticateToken,
  notebookController.updateNotebook,
);
router.delete(
  "/delete-notebook/:notebookId",
  authenticateToken,
  notebookController.deleteNotebook,
);
router.get(
  "/read-notebook/:notebookId",
  authenticateToken,
  notebookController.readNotebook,
);
router.get("/search", authenticateToken, notebookController.searchNotebooks);
router.get(
  "/all/:userId",
  authenticateToken,
  notebookController.getAllNotebooks,
);
router.get(
  "/:userId/:notebookId",
  authenticateToken,
  notebookController.getNotebookById,
);

module.exports = router;
