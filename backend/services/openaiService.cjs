// const OpenAI = require("openai").default;
// const dotenv = require("dotenv");

// // Load environment variables
// dotenv.config({ path: "../../.env" });

// const openai = new OpenAI({
//   apiKey: process.env.OPENAI_API_KEY, // Ensure this is set in your .env
// });

// /**
//  * Extract important tags from the given text.
//  * The AI should return a JSON array of strings.
//  * Example: ["Mary", "Orlando", "Task A"]
//  *
//  * @param {string} journalContent - The content of the journal entry.
//  * @returns {Promise<string[]>} - Array of extracted tags.
//  */
// async function extractTags(journalContent) {
//   const messages = [
//     {
//       role: "system",
//       content:
//         "You are a helpful assistant that extracts tags from text. " +
//         "You should return only valid JSON and nothing else.",
//     },
//     {
//       role: "user",
//       content: `
//           Extract important names, places, tasks, or keywords from the following text. 
//           Return only a valid JSON object (dictionary) where:
//             - Each key is the tag (string).
//             - Each value is the classification, which must be one of: "person", "place", "task", or "keyword".

//           Example valid JSON:
//           {
//             "Mary": "person",
//             "Orlando": "place",
//             "Fix the door": "task",
//             "JavaScript": "keyword"
//           }

//           If no tags are found, return an empty JSON object: {}

//           Do not include any additional keys or text in your response.

//           Text:
//           "${journalContent}"
//         `,
//     },
//   ];

//   try {
//     const response = await openai.chat.completions.create({
//       model: "gpt-3.5-turbo", // or "gpt-4" if you have access
//       messages,
//     });

//     const rawText = response.choices[0].message.content.trim();
//     // Attempt to parse the text as JSON
//     const tagsObject = JSON.parse(rawText);

//     // Ensure it's an object (not an array or null)
//     if (
//       typeof tagsObject !== "object" ||
//       tagsObject === null ||
//       Array.isArray(tagsObject)
//     ) {
//       throw new Error("The response is not a JSON object.");
//     }

//     // Optional: Validate that each value is one of the allowed classifications
//     const allowedTypes = ["person", "place", "task", "keyword"];
//     for (const [tag, classification] of Object.entries(tagsObject)) {
//       if (!allowedTypes.includes(classification)) {
//         console.warn(
//           `Tag "${tag}" has unrecognized classification: "${classification}"`,
//         );
//       }
//     }

//     return tagsObject;
//   } catch (error) {
//     console.error("Error extracting tags:", error);
//     // Return an empty object on failure
//     return {};
//   }
// }

// /**
//  * Helper to build a ChatCompletion prompt based on tagType,
//  * with expanded fields for each profile type.
//  */
// function buildProfilePrompt(tag, tagType, notebookContents) {
//   // Combine all notebook contents into one string
//   const combinedNotes = notebookContents.join("\n\n");

//   let fieldInstructions;
//   switch (tagType) {
//     case "person":
//       fieldInstructions = `
//           Return valid JSON with the following fields:
//           {
//             "name": string or null,
//             "age": string or null,
//             "occupation": string or null,
//             "location": string or null,
//             "education": string or null,
//             "interests": array of strings or [],
//             "otherDetails": string or null
//           }
//         `;
//       break;
//     case "place":
//       fieldInstructions = `
//           Return valid JSON with the following fields:
//           {
//             "name": string or null,
//             "city": string or null,
//             "region": string or null,
//             "country": string or null,
//             "climate": string or null,
//             "population": string or null,
//             "landmarks": array of strings or [],
//             "otherDetails": string or null
//           }
//         `;
//       break;
//     case "task":
//       fieldInstructions = `
//           Return valid JSON with the following fields:
//           {
//             "description": string or null,
//             "assignedTo": string or null,
//             "priority": string or null,
//             "deadline": string or null,
//             "status": string or null,
//             "otherDetails": string or null
//           }
//         `;
//       break;
//     default:
//       // "keyword" or fallback
//       fieldInstructions = `
//           Return valid JSON with the following fields:
//           {
//             "info": string or null,
//             "definition": string or null,
//             "context": string or null,
//             "otherDetails": string or null
//           }
//         `;
//       break;
//   }

//   return [
//     {
//       role: "system",
//       content:
//         "You are a helpful assistant that creates structured profiles from user notes. " +
//         "Return only valid JSON with no extra text.",
//     },
//     {
//       role: "user",
//       content: `
//           We have a tag named "${tag}" of type "${tagType}".
//           Below are notebook contents mentioning this tag.

//           ${fieldInstructions}

//           NOTES:
//           ${combinedNotes}

//           If a field isn't mentioned, set it to null or empty.
//           Return valid JSON only, with no extra text.
//         `,
//     },
//   ];
// }

// /**
//  * POST /profile/create-profile
//  * Body: { "tag": string, "tagType": string, "notebookContents": string[] }
//  */
// // 3. CREATE PROFILE ENDPOINT HANDLER
// async function createProfile(req, res) {
//   try {
//     const { tag, tagType, notebookContents } = req.body;
//     const messages = buildProfilePrompt(tag, tagType, notebookContents);

//     const response = await openai.chat.completions.create({
//       model: "gpt-3.5-turbo",
//       messages,
//     });

//     const rawText = response.choices[0].message.content.trim();
//     let profileData;
//     try {
//       profileData = JSON.parse(rawText);
//     } catch (parseError) {
//       return res.status(500).json({
//         error: "Failed to parse JSON from OpenAI. Raw response: " + rawText,
//       });
//     }

//     return res.status(200).json({
//       tag,
//       tagType,
//       profile: profileData,
//     });
//   } catch (error) {
//     console.error("Error creating profile:", error);
//     return res.status(500).json({ error: error.message });
//   }
// }

// module.exports = {
//   extractTags,
//   createProfile,
// };



/////////OPENAI JUST FOR NAMES

const OpenAI = require("openai").default;
const dotenv = require("dotenv");

// Load environment variables
dotenv.config({ path: "../../.env" });

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Ensure this is set in your .env
});

/**
 * Extract names from the given text.
 * The AI should return only a valid JSON array of names.
 * Example: ["Mary", "John", "Alice"]
 *
 * @param {string} journalContent - The content of the journal entry.
 * @returns {Promise<string[]>} - Array of extracted names.
 */
async function extractTags(journalContent) {
  const messages = [
    {
      role: "system",
      content:
        "You are a helpful assistant that extracts names from text. " +
        "Return only a valid JSON array of names with no extra text.",
    },
    {
      role: "user",
      content: `
          Extract all important names (people) from the following text.
          Return only a valid JSON array.
          Example: ["Mary", "John", "Alice"]
          If no names are found, return an empty JSON array: []
  
          Text:
          "${journalContent}"
        `,
    },
  ];

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages,
    });

    const rawText = response.choices[0].message.content.trim();
    const namesArray = JSON.parse(rawText);

    if (!Array.isArray(namesArray)) {
      throw new Error("The response is not a JSON array.");
    }

    return namesArray;
  } catch (error) {
    console.error("Error extracting names:", error);
    return [];
  }
}

/**
 * Build a profile prompt for a given name with extra fields.
 * This prompt instructs the AI to build an extremely detailed profile for a person.
 *
 * @param {string} name - The name for which to build a profile.
 * @param {string[]} notebookContents - An array of notebook content strings.
 * @returns {Array} - The messages array for the OpenAI Chat API.
 */
function buildProfilePrompt(name, notebookContents) {
  const combinedNotes = notebookContents.join("\n\n");
  const fieldInstructions = `
    Return valid JSON with the following fields:
    {
      "name": string or null,
      "age": string or null,
      "occupation": string or null,
      "location": string or null,
      "education": string or null,
      "interests": array of strings or [],
      "hobbies": array of strings or [],
      "skills": array of strings or [],
      "experience": string or null,
      "personalityTraits": array of strings or [],
      "goals": string or null,
      "challenges": string or null,
      "background": string or null,
      "affiliations": array of strings or [],
      "socialMedia": {
          "twitter": string or null,
          "linkedin": string or null,
          "facebook": string or null,
          "instagram": string or null
      },
      "favoriteBooks": array of strings or [],
      "favoriteMovies": array of strings or [],
      "favoriteMusic": array of strings or [],
      "additionalNotes": string or null
    }
  `;
  return [
    {
      role: "system",
      content:
        "You are a helpful assistant that builds extremely detailed structured profiles for people. Return only valid JSON with no extra text.",
    },
    {
      role: "user",
      content: `
          We have a person named "${name}".
          Below are notebook contents mentioning this person.
  
          ${fieldInstructions}
  
          NOTES:
          ${combinedNotes}
  
          If a field isn't mentioned, set it to null or an empty array/object as appropriate.
          Return valid JSON only, with no extra text.
        `,
    },
  ];
}

/**
 * Create a profile for a given name.
 * Expects a request body with { "name": string, "notebookContents": string[] }.
 */
async function createProfile(req, res) {
  try {
    const { name, notebookContents } = req.body;
    const messages = buildProfilePrompt(name, notebookContents);

    const response = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages,
    });

    const rawText = response.choices[0].message.content.trim();
    let profileData;
    try {
      profileData = JSON.parse(rawText);
    } catch (parseError) {
      return res.status(500).json({
        error: "Failed to parse JSON from OpenAI. Raw response: " + rawText,
      });
    }

    return res.status(200).json({
      name,
      profile: profileData,
    });
  } catch (error) {
    console.error("Error creating profile:", error);
    return res.status(500).json({ error: error.message });
  }
}

module.exports = {
  extractTags,
  buildProfilePrompt,
  createProfile,
};
