const Profile = require("../models/summary");
const Notebook = require("../models/notebook");
const openaiService = require("./openaiService.cjs");

function formatProfileContent(data) {
  return `Name: ${data.name}
Nickname: ${data.nickname || "N/A"}
Birthday: ${data.birthday || "N/A"}
Age: ${data.age || "N/A"}
Occupation: ${data.occupation || "N/A"}
Location: ${data.location || "N/A"}
Education: ${data.education || "N/A"}
Interests: ${data.interests?.join(", ") || "N/A"}
Hobbies: ${data.hobbies?.join(", ") || "N/A"}
Skills: ${data.skills?.join(", ") || "N/A"}
Experience: ${data.experience || "N/A"}
Personality Traits: ${data.personalityTraits?.join(", ") || "N/A"}
Goals: ${data.goals || "N/A"}
Challenges: ${data.challenges || "N/A"}
Background: ${data.background || "N/A"}
Affiliations: ${data.affiliations?.join(", ") || "N/A"}
Favorite Books: ${data.favoriteBooks?.join(", ") || "N/A"}
Favorite Movies: ${data.favoriteMovies?.join(", ") || "N/A"}
Favorite Music: ${data.favoriteMusic?.join(", ") || "N/A"}
Achievements: ${data.achievements?.join(", ") || "N/A"}
Family: ${data.family || "N/A"}
Relationship Status: ${data.relationshipStatus || "N/A"}
Memorable Quotes: ${data.memorableQuotes?.join("\n- ") || "N/A"}
Additional Notes: ${data.additionalNotes || "N/A"}`;
}

exports.updateProfilesForNotebook = async (notebook, operation) => {
  if (operation === "create" || operation === "update") {
    const namesArray = await openaiService.extractTags(notebook.content);
    notebook.tags = Array.isArray(namesArray) ? namesArray : [];
    await notebook.save();

    for (const name of notebook.tags) {
      let profile = await Profile.findOne({
        profileTitle: name,
        userId: notebook.userId,
      });

      if (profile) {
        if (!profile.notebookIDs.includes(notebook._id)) {
          profile.notebookIDs.push(notebook._id);
        }
      } else {
        profile = new Profile({
          profileTitle: name,
          userId: notebook.userId,
          notebookIDs: [notebook._id],
        });
      }

      const notebooks = await Notebook.find({
        _id: { $in: profile.notebookIDs },
      });
      const notebookContents = notebooks.map((n) => n.content);

      const profileData = await openaiService.createProfile(
        name,
        notebookContents,
      );
      if (profileData) {
        profile.profileTitle = profileData.name || profile.profileTitle;
        profile.profileContent = formatProfileContent(profileData);
      }
      profile.timeUpdated = Date.now();
      await profile.save();
    }
  } else if (operation === "delete") {
    const profiles = await Profile.find({ notebookIDs: notebook._id });
    for (const profile of profiles) {
      profile.notebookIDs = profile.notebookIDs.filter(
        (id) => id.toString() !== notebook._id.toString(),
      );

      if (profile.notebookIDs.length === 0) {
        await Profile.findByIdAndDelete(profile._id);
      } else {
        const notebooks = await Notebook.find({
          _id: { $in: profile.notebookIDs },
        });
        const notebookContents = notebooks.map((n) => n.content);
        const profileData = await openaiService.createProfile(
          profile.profileTitle,
          notebookContents,
        );
        if (profileData) {
          profile.profileTitle = profileData.name || profile.profileTitle;
          profile.profileContent = formatProfileContent(profileData);
        }
        profile.timeUpdated = Date.now();
        await profile.save();
      }
    }
  }
};
