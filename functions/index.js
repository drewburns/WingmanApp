
/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const functions = require('firebase-functions');
const admin = require('firebase-admin');
// let string = "https://wingman-notifs.herokuapp.com/send?token=" + (self.user?.token)! + "&alert=" + alert

admin.initializeApp(functions.config().firebase);

exports.addedFake = functions.database.ref('/fakes').onWrite(event => {


});

exports.addAccount = functions.auth.user().onCreate(event => {
	const user = event.data; // The firebase user
	const user_id = user.uid;
	const number = user.providerData.uid

	var timestamp = Math.floor(Date.now()/1000)

	const root = event.data.ref.root;
	return root.child(`user-pending/${number}`).once('value')
	.then((snapshot) => {
		var promises = [];
		const data = snapshot.val();
		for (var pending in data) {
			for (var x in pending) {
				const setUpUId = pending[x]["setUpId"];
				const fromId = pending[x]["fromId"];
				const text = pending[x]["text"];
			}



			var setUpRef = admin.database().ref(`setup`).push();
			setUpRef.set({ "n": 10, "timestamp" : timestamp , "user1": user_id, "fromId": fromId  });
			promises.push(setUpRef)

			var keystring10 = setUpRef.key

			var fields10 = keystring10.split('/');

			var setupkey = fields10[fields10.length - 1]

			var firstMessageRef = admin.database().ref(`messages`).push();
			firstMessageRef.set({ "first": true, "fromId": fromId, "toId": user_id, "read": false,
			 "setupId": setupkey, "text": text , "timestamp": timestamp, "userWhoSetUp": setUpUId});
			promises.push(firstMessageRef);

			var keystring20 = firstMessageRef.key

			var fields20 = keystring20.split('/');

			var messageKey = fields20[fields20.length - 1]

			var user1MessageRef = admin.database().ref(`user-message/${fromId}/${toId}`);
			user1MessageRef.set({ [messageKey]: 1 });
			promises.push(user1MessageRef);

			var user2MessageRef = admin.database().ref(`user-message/${toId}/${fromId}`);
			user2MessageRef.set({ [messageKey]: 1 });
			promises.push(user2MessageRef);

			var userSetUpRef = admin.database().ref(`user-setup/${setUpUId}`);
			userSetUpRef.set({ [setupkey] : 1 });
			promises.push(userSetUpRef);

			var setUpMessagesRef = admin.database().ref(`setup-messages/${setupkey}`);
			setUpMessagesRef.set({ [messageKey] : 1 })
			promises.push(setUpMessagesRef);
		}
		
			var newMessage1 = admin.database().ref("messages").push();
			newMessage1.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
			 "text": "Welcome to Wingman!", "timestamp": timestamp, "toId": user_id });
			promises.push(newMessage1);
			console.log("newGroupUser")
			console.log(promises)

			var keystring1 = newMessage1.key

			var fields1 = keystring1.split('/');

			var key1 = fields1[fields1.length - 1]

			// var newUserMessage1 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
			// newUserMessage1.set({ [key1] : 0 });
			// promises.push(newUserMessage1);

			var newMessage2 = admin.database().ref("messages").push();
			newMessage2.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
			 "text": "View the following images to learn how to use Wingman", "timestamp": timestamp, "toId": user_id });
			promises.push(newMessage2);
			console.log("newGroupUser")
			console.log(promises)

			var keystring2 = newMessage2.key

			var fields2 = keystring2.split('/');

			var key2 = fields2[fields2.length - 1]

			// var newUserMessage2 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
			// newUserMessage2.set({ [key2] : 0 });
			// promises.push(newUserMessage2);

			var newMessage3 = admin.database().ref("messages").push();
			newMessage3.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
			"timestamp": timestamp, "toId": user_id,  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/wingman-d2039.appspot.com/o/screenshot1.png?alt=media&token=207face9-3833-4aaa-b7fd-1ffa0e516fb3",
			"imageHeight" : 1136 , "imageWidth" : 640 });
			promises.push(newMessage3);
			console.log("newGroupUser")
			console.log(promises)

			var keystring3 = newMessage3.key

			var fields3 = keystring3.split('/');

			var key3 = fields3[fields3.length - 1]

			// var newUserMessage3 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
			// newUserMessage3.set({ [key3] : 0 });
			// promises.push(newUserMessage3);

			var newMessage4 = admin.database().ref("messages").push();
			newMessage4.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
			"timestamp": timestamp, "toId": user_id,  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/wingman-d2039.appspot.com/o/screenshot2.png?alt=media&token=b6909247-2872-4612-9e56-98c480067982",
			"imageHeight" : 1136 , "imageWidth" : 640 });
			promises.push(newMessage4);
			console.log("newGroupUser4")
			console.log(promises)

			var keystring4 = newMessage4.key

			var fields4 = keystring4.split('/');

			var key4 = fields4[fields4.length - 1]

			var newUserMessage4 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
			newUserMessage4.set({ [key4] : 0, [key3] : 0, [key2] : 0 , [key1] : 0  });
			promises.push(newUserMessage4);

		// maybe send notifs here

		return Promise.all(promises)
	})
	.then((result) => {
		console.log('2/Step');
		// Perform some manipulation over result. But meanwhile:
		return result;
	})
	.catch((err) => {
		console.log(`Failed with error info: ${err}`);
		return err
	});

	// var pendings = []
	// var getUserPendings = firebase.database().ref(`user-pending/${number}`);
	// getUserPendings.once('value').then(snapshot => {
	// 	pendings = snapshot.val();
	// });

	// var pending;
	// for (pending in pendings) {
	// 	var setUpUId = ""
	// 	var fromId = ""
	// 	var text = ""
	// 	var getPending = firebase.database().ref(`pending/${pending.key}`);
	// 	getPending.once('value').then(snapshot => {
	// 		setUpUId = snapshot.child("setUpId").val();
	// 		fromId = snapshot.child("fromId").val();
	// 		text = snapshot.child("text").val();	
	// 	});


	// 	var setUpRef = admin.database().ref("setup").push();
	// 	setUpRef.set({ "n": 10, "timestamp" : timestamp , "user1": user_id, "fromId": fromId  });
	// 	promises.push(setUpRef)

	// 	var keystring10 = setUpRef.key

	// 	var fields10 = keystring10.split('/');

	// 	var setupkey = fields10[fields10.length - 1]

	// 	var firstMessageRef = admin.database().ref(`messages`).push();
	// 	firstMessageRef.set({ "first": true, "fromId": fromId, "toId": user_id, "read": false,
	// 	 "setupId": setupkey, "text": text , "timestamp": timestamp, "userWhoSetUp": setUpUId});
	// 	promises.push(firstMessageRef);

	// 	var keystring20 = firstMessageRef.key

	// 	var fields20 = keystring20.split('/');

	// 	var messageKey = fields20[fields20.length - 1]

	// 	var user1MessageRef = admin.database().ref(`user-message/${fromId}/${toId}`);
	// 	user1MessageRef.set({ [messageKey]: 1 });
	// 	promises.push(user1MessageRef);

	// 	var user2MessageRef = admin.database().ref(`user-message/${toId}/${fromId}`);
	// 	user2MessageRef.set({ [messageKey]: 1 });
	// 	promises.push(user2MessageRef);

	// 	var userSetUpRef = admin.database().ref(`user-setup/${setUpUId}`);
	// 	userSetUpRef.set({ [setupkey] : 1 });
	// 	promises.push(userSetUpRef);

	// 	var setUpMessagesRef = admin.database().ref(`setup-messages/${setupkey}`);
	// 	setUpMessages.set({ [messageKey] : 1 })

	// 	// maybe send notifs here


	// }

	//

	// var newMessage1 = admin.database().ref("messages").push();
	// newMessage1.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
	//  "text": "Welcome to Wingman!", "timestamp": timestamp, "toId": user_id });
	// promises.push(newMessage1);
	// console.log("newGroupUser")
	// console.log(promises)

	// var keystring1 = newMessage1.key

	// var fields1 = keystring1.split('/');

	// var key1 = fields1[fields1.length - 1]

	// // var newUserMessage1 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
	// // newUserMessage1.set({ [key1] : 0 });
	// // promises.push(newUserMessage1);

	// var newMessage2 = admin.database().ref("messages").push();
	// newMessage2.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
	//  "text": "View the following images to learn how to use Wingman", "timestamp": timestamp, "toId": user_id });
	// promises.push(newMessage2);
	// console.log("newGroupUser")
	// console.log(promises)

	// var keystring2 = newMessage2.key

	// var fields2 = keystring2.split('/');

	// var key2 = fields2[fields2.length - 1]

	// // var newUserMessage2 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
	// // newUserMessage2.set({ [key2] : 0 });
	// // promises.push(newUserMessage2);

	// var newMessage3 = admin.database().ref("messages").push();
	// newMessage3.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
	// "timestamp": timestamp, "toId": user_id,  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/wingman-d2039.appspot.com/o/screenshot1.png?alt=media&token=207face9-3833-4aaa-b7fd-1ffa0e516fb3",
	// "imageHeight" : 1136 , "imageWidth" : 640 });
	// promises.push(newMessage3);
	// console.log("newGroupUser")
	// console.log(promises)

	// var keystring3 = newMessage3.key

	// var fields3 = keystring3.split('/');

	// var key3 = fields3[fields3.length - 1]

	// // var newUserMessage3 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
	// // newUserMessage3.set({ [key3] : 0 });
	// // promises.push(newUserMessage3);

	// var newMessage4 = admin.database().ref("messages").push();
	// newMessage4.set({ "fromId": "UjVfdbeATnckVWUZBV5jJBsu2At2", "read": false,
	// "timestamp": timestamp, "toId": user_id,  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/wingman-d2039.appspot.com/o/screenshot2.png?alt=media&token=b6909247-2872-4612-9e56-98c480067982",
	// "imageHeight" : 1136 , "imageWidth" : 640 });
	// promises.push(newMessage4);
	// console.log("newGroupUser4")
	// console.log(promises)

	// var keystring4 = newMessage4.key

	// var fields4 = keystring4.split('/');

	// var key4 = fields4[fields4.length - 1]

	// var newUserMessage4 = admin.database().ref(`user-message/${user_id}/UjVfdbeATnckVWUZBV5jJBsu2At2`)
	// newUserMessage4.set({ [key4] : 0, [key3] : 0, [key2] : 0 , [key1] : 0  });
	// promises.push(newUserMessage4);

	// return Promise.all(promises);

});
// on user create
// create a few messages to the current user from the id of Wingman
// probably send them as image messages so link an image with instructions

// -Kwc5T3_ckBra-wG6NUO
// 	fromId: 
// 	"1PWPvK1TixQCLegOIzwsILhJLFG2"
// 	imageHeight: 
// 	1136
// 	imageUrl: 
// 	"https://firebasestorage.googleapis.com/v0/b/wingman-d2039.appspot.com/o/UjVfdbeATnckVWUZBV5jJBsu2At2-profile.png?alt=media&token=9d325694-039a-4098-aa31-5c8367fe734b"
// 	imageWidth: 
// 	640
// 	read: 
// 	true
// 	timestamp: 
// 	1508206305
// 	toId: 
// 	"ZJvtjVAiK9R3O8a3UEtF4jOby242"



// -Kw8bencbjC6NtMXKBCL
// 	fromId: 
// 	"HL9VlOyiJBYNzWnTAodtaPmWXLz1"
// 	read: 
// 	true
// 	text: 
// 	"It’s the same damn thing"
// 	timestamp: 
// 	1507694914
// 	toId: 
// 	"ZJvtjVAiK9R3O8a3UEtF4jOby242"
