const Profile = require("../models/summary");
const Notebook = require("../models/notebook");
const openaiService = require("./openaiService.cjs");

exports.updateProfilesForNotebook = async (notebook, operation) => {
    if (operation === "create" || operation === "update") {
        // Extract names (tags) from the notebook content using OpenAI
        const namesArray = await openaiService.extractTags(notebook.content);
        // Expect namesArray to be something like: ["Alice", "Bob"]
        notebook.tags = Array.isArray(namesArray) ? namesArray : [];
        await notebook.save();

        // Process each extracted name
        for (const name of notebook.tags) {
            let profile = await Profile.findOne({ profileTitle: name });
            if (profile) {
                // Append the notebook ID if not already present
                if (!profile.notebookIDs.includes(notebook._id)) {
                    profile.notebookIDs.push(notebook._id);
                }
            } else {
                // Create a new profile for this name
                profile = new Profile({
                    profileTitle: name,
                    profileContent: "", // Will be built below
                    userId: notebook.userId,
                    notebookIDs: [notebook._id],
                });
            }
            // Gather content from all notebooks linked to this profile
            const notebooks = await Notebook.find({ _id: { $in: profile.notebookIDs } });
            const notebookContents = notebooks.map(n => n.content);
            // Build/update the profile content using OpenAI service
            profile.profileContent = await openaiService.buildProfilePrompt(name, notebookContents);
            await profile.save();
        }
    } else if (operation === "delete") {
        // For deletion, remove the notebook ID from any profiles that reference it
        const profiles = await Profile.find({ notebookIDs: notebook._id });
        for (const profile of profiles) {
            profile.notebookIDs = profile.notebookIDs.filter(
                id => id.toString() !== notebook._id.toString()
            );
            if (profile.notebookIDs.length === 0) {
                // Optionally, delete the profile if no notebooks remain
                await Profile.findByIdAndDelete(profile._id);
            } else {
                // Otherwise, rebuild the profile with the remaining notebooks
                const notebooks = await Notebook.find({ _id: { $in: profile.notebookIDs } });
                const notebookContents = notebooks.map(n => n.content);
                profile.profileContent = await openaiService.buildProfilePrompt(profile.profileTitle, notebookContents);
                await profile.save();
            }
        }
    }
};
