/**
 * Importing the dependancies
 */
var express = require('express'),
	mysql = require('mysql'),
	moment = require('moment'),
	router = express.Router(),
	login = require('./../../helpers/login'),
	databaseConfig = require('./../../config/database'),
	getCopyrightDate = require('./../../helpers/copyright'),
	formater = require('./../../helpers/formater');



/**
 * Configurations
 */
var conn = mysql.createConnection({
	database: databaseConfig.name,
	host: databaseConfig.host,
	password: databaseConfig.password,
	user: databaseConfig.user,
	multipleStatements: true
});



/**
 * Connecting to the database
 */
conn.connect();



/**
 * Setting up the local timezone
 */
moment.locale('ar-ma');



/**
 * Routing
 */

// Setting up the mail retrieval route.
router.get('/read/:id', login, function (req, res) {
	const mailId = req.params.id;

	stmt = mysql.format(
		'\
        SELECT * FROM ?? WHERE ?? = ?;\
        UPDATE ?? SET ?? = ? WHERE ?? = ?;\
        SELECT COUNT(*) AS ?? FROM ?? WHERE ?? = 0; \
        ',
		['Mail', 'MailID', mailId, 'Mail', 'Read', 1, 'MailID', mailId, 'MailCount', 'Mail', 'Read']
	);

	conn.query(stmt, (error, results) => {
		if (error) throw error;

		results[0][0].IssueDate = moment(results[0][0].IssueDate).format('HH:MM - MMMM Do YYYY');

		res.json({ email: { ...results[0][0] }, MailCount: results[2][0]['MailCount'] });
	});
});

// Setting up the default mail route.
router.get('/', login, function (req, res) {
	res.redirect('/dashboard/mail/0');
});

// Setting up the mail route.
router.get('/:mode', login, function (req, res) {
	const mode =
		req.params.mode > 2 ? 2 : req.params.mode < 0 ? 0 : req.params.mode;

	conn.query(
		'\
        SELECT `PrimaryNumber`, `SecondaryNumber`, `FixedNumber`, `Email`, `Facebook`, `Instagram`, `Youtube` FROM `Config`;\
        SELECT * FROM `Categories` WHERE `Deleted` = 0;\
        SELECT * FROM `Mail` ' +
		(mode == 0 ? '' : mode == 1 ? 'WHERE `Read` = 1' : 'WHERE `Read` = 0') +
		' ORDER BY `IssueDate` DESC;\
        SELECT COUNT(`MailID`) AS `NewMail` FROM `Mail` WHERE `Read` = 0;\
    ',
		(error, results) => {
			// Checking if there are any errors.
			if (error) throw error;

			// Getting the data.
			const data = {
				Config: {
					Phone: {
						Primary: results[0][0].PrimaryNumber,
						Secondary: results[0][0].SecondaryNumber,
						Fixed: results[0][0].FixedNumber
					},
					Email: results[0][0].Email,
					Facebook: {
						Name: results[0][0].Facebook.split('|')[0],
						Link: results[0][0].Facebook.split('|')[1]
					},
					Instagram: {
						Name: results[0][0].Instagram.split('|')[0],
						Link: results[0][0].Instagram.split('|')[1]
					},
					Youtube: {
						Name: results[0][0].Youtube.split('|')[0],
						Link: results[0][0].Youtube.split('|')[1]
					}
				},
				Categories: formater.groupCategories(results[1]),
				Mail: formater.truncateMessages(results[2]),
				NewMail: results[3][0].NewMail,
				Mode: mode
			};

			// Getting the proper copyright date.
			data.CopyrightDate = getCopyrightDate();

			// Rendering the mail page.
			res.render('dashboard/mail', {
				Data: data
			});
		}
	);
});

// Setting up the mail creation route.
router.post('/', function (req, res) {
	var mail = {
		username: req.body.username,
		email: req.body.email,
		message: req.body.message
	},
		stmt = mysql.format(' \
				INSERT INTO ?? (??, ??, ??, ??, ??) VALUES (?, ?, ?, NOW(), ?); \
			 	SELECT COUNT(*) AS ?? FROM ?? WHERE ?? = 0; \
			',
			[
				'Mail',
				'SenderEmail',
				'SenderName',
				'Message',
				'IssueDate',
				'Read',
				mail.email,
				mail.username,
				mail.message,
				0,
				'MailCount',
				'Mail',
				'Read'
			]
		);

	conn.query(stmt, (error, results) => {
		let isSent = true;

		if (error) isSent = false;

		res.json({ sent: isSent, mailCount: results[1][0]['MailCount'] });
	});
});

// Setting up the mail update (read) route.
router.delete('/', login, function (req, res) {
	const ids = req.body.ids,
		stmt = mysql.format(' \
				UPDATE ?? SET ?? = ? WHERE ?? IN (?); \
				SELECT COUNT(*) AS ?? FROM ?? WHERE ?? = 0; \
			', [
				'Mail',
				'Read',
				1,
				'MailID',
				ids,
				'MailCount',
				'Mail',
				'Read'
			]);

	conn.query(stmt, (error, results) => {
		if (error) throw error;

		res.json(results[1][0]['MailCount']);
	});
});

// Setting up the mail update (unread) route.
router.put('/', login, function (req, res) {
	const ids = req.body.ids,
		stmt = mysql.format(' \
				UPDATE ?? SET ?? = ? WHERE ?? IN (?); \
				SELECT COUNT(*) AS ?? FROM ?? WHERE ?? = 0; \
		', [
				'Mail',
				'Read',
				0,
				'MailID',
				ids,
				'MailCount',
				'Mail',
				'Read'
			]);

	conn.query(stmt, (error, results) => {
		if (error) throw error;

		res.json(results[1][0]['MailCount']);
	});
});

// Exporting the route.
module.exports = router;
