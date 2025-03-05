const Notebook = require('../models/notebook');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');


exports.createNotebook = async (req, res) => {
	try {
		const { userId, title, content } = req.body;

		//creation of tags using openai should go here
		//tags placeholder
		let tags = ["name", "place"];

		//create new notebook
		const newNotebook = new Notebook({
			title,
			content,
			tags,
			userId,
		});
		await newNotebook.save();


	} catch (error) {
		res.status(500).json({error: error.message });
	}
}

exports.readNotebook = async (req, res) => {
	try{

	} catch (error) {

	}	
	
}

exports.updateNotebook = async (req, res) => {

}

exports.deleteNotebook = async (req, res) => {

}
