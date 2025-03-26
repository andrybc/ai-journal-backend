const Notebook = require("../models/notebook");
const profileService = require("../services/profileService");

exports.createNotebook = async (req, res) => {
    try {
        const { title, content, userId } = req.body;

        // Create a new notebook (initially, tags are empty; they will be updated by the profile service)
        const newNotebook = new Notebook({
            title,
            content,
            tags: [],
            userId,
        });
        await newNotebook.save();

        // Update profiles based on this notebook (operation "create")
        await profileService.updateProfilesForNotebook(newNotebook, "create");

        res.status(200).json({ message: "Notebook created successfully", notebook: newNotebook });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.updateNotebook = async (req, res) => {
    try {
        const { notebookId } = req.params;
        const { title, content } = req.body;

        // Update the notebook; setting tags to empty array so that they are recalculated
        const updatedNotebook = await Notebook.findByIdAndUpdate(
            notebookId,
            { title, content, tags: [] },
            { new: true }
        );
        if (!updatedNotebook) {
            return res.status(404).json({ error: "Notebook not found" });
        }

        // Update profiles based on the updated notebook (operation "update")
        await profileService.updateProfilesForNotebook(updatedNotebook, "update");

        res.status(200).json({ message: "Notebook updated successfully", notebook: updatedNotebook });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.deleteNotebook = async (req, res) => {
    try {
        const { notebookId } = req.params;

        // Find the notebook first
        const notebook = await Notebook.findById(notebookId);
        if (!notebook) {
            return res.status(404).json({ error: "Notebook not found" });
        }

        // Delete the notebook
        await Notebook.findByIdAndDelete(notebookId);

        // Update profiles for this notebook (operation "delete")
        await profileService.updateProfilesForNotebook(notebook, "delete");

        res.status(200).json({ message: "Notebook successfully deleted" });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.readNotebook = async (req, res) => {
    try {
        const { notebookId } = req.params;
        const notebook = await Notebook.findById(notebookId);
        if (!notebook) {
            return res.status(404).json({ error: "Notebook not found" });
        }
        res.status(200).json({ message: "Notebook retrieved", notebook });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};
