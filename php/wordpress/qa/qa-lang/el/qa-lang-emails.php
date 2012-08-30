<?php
	
/*
	Question2Answer (c) Stamatis Ezovalis

	http://www.question2answer.org/

	
	File: qa-lang/el/qa-lang-emails.php
	Version: 1.5.2
	Date: 2012-30-08 13:42:51 GMT+2
	Description: Language phrases in Greek for email notifications


	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	More about this license: http://www.question2answer.org/license.php
*/

	return array(
		'a_commented_body' => "Η απάντησή σας στο ^site_title έχει ένα νέο σχόλιο από τον χρήστη ^c_handle:\n\n^open^c_content^close\n\nΗ απάντηση ήταν :\n\n^open^c_context^close\n\nΜπορείτε να απαντήσετε, προσθέτοντας το δικό σας σχόλιο:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'a_commented_subject' => 'Η απάντησή σας στο ^site_title έχει ένα νέο σχόλιο',

		'a_followed_body' => "Η απάντησή σας στο ^site_title έχει μία νέα σχετική ερώτηση από τον χρήστη ^q_handle:\n\n^open^q_title^close\n\nΗ απάντησή σας ήταν:\n\n^open^a_content^close\n\nΚάντε κλικ παρακάτω για να απαντήσετε στη νέα ερώτηση:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'a_followed_subject' => 'Η απάντησή σας στο ^site_title έχει μια νέα σχετική ερώτηση',

		'a_selected_body' => "Συγχαρητήρια! Η απάντησή σας στο ^site_title επιλέχθηκε ως η καλύτερη από τον χρήστη ^s_handle:\n\n^open^a_content^close\n\nΗ ερώτηση ήταν:\n\n^open^q_title^close\n\nΚάντε κλικ παρακάτω για να δείτε την απάντησή σας:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'a_selected_subject' => 'Η απάντησή σας στο ^site_title επιλέχθηκε!',

		'c_commented_body' => "Ένα σχόλιο από τον χρήστη ^c_handle προστέθηκε μετά το σχόλιό σας ^site_title:\n\n^open^c_content^close\n\nΗ συζήτηση ακολουθεί:\n\n^open^c_context^close\n\nΜπορείτε να απαντήσετε προσθέτοντας ένα άλλο σχόλιο:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'c_commented_subject' => 'Το σχόλιό σας στο ^site_title προστέθηκε',

		'confirm_body' => "Παρακαλώ κάντε κλικ παρακάτω για να επιβεβαιώσετε το email σας για το ^site_title.\n\n^url\n\nΕυχαριστούμε,\n^site_title",
		'confirm_subject' => '^site_title - Επιβεβαίωση email',

		'feedback_body' => "Σχόλια:\n^message\n\nΌνομα:\n^name\n\nEmail:\n^email\n\nΠροηγούμενη σελίδα:\n^previous\n\nΧρήστης:\n^url\n\nIP:\n^ip\n\nBrowser:\n^browser",
		'feedback_subject' => '^ επικοινωνία - σχόλιο',

		'flagged_body' => "Μια δημοσίευση από ^p_handle έχει παραληφθεί ^flags:\n\n^open^p_context^close\n\nΚάντε κλικ παρακάτω για να δείτε τη δημοσίευση:\n\n^url\n\nnΕυχαριστούμε,\n\n^site_title",
		'flagged_subject' => '^site_title υπάρχει σημασμένη δημοσίευση',

		'moderate_body' => "Μια δημοσίευση από ^p_handle αναμένει για έγκριση:\n\n^open^p_context^close\n\nΚάντε κλικ παρακάτω για να εγκρίνεται ή να απορρίψετε τη δημοσίευση:\n\n^url\n\nnΕυχαριστούμε,\n\n^site_title",
		'moderate_subject' => '^site_title moderation',

		'new_password_body' => "Το νέο σας password για το ^site_title είναι το παρακάτω.\n\nPassword: ^password\n\nΣας προτείνουμε να αλλάξετε αυτό το password αμέσως μόλις συνδεθείτε.\n\nΕυχαριστούμε,\n^site_title\n^url",
		'new_password_subject' => '^site_title - Το νέο σας password',

		'private_message_body' => "Σας έχει αποσταλεί ένα προσωπικό μήνυμα από ^f_handle on ^site_title:\n\n^open^message^close\n\n^moreΕυχαριστούμε,\n\n^site_title\n\n\nΓια να απενεργοποιήσετε τα λήψη προσωπικών μηνυμάτων, επισκεφθείτε τη σελίδα του λογαριασμού σας:\n^a_url",
		'private_message_info' => "Περισσότερες πληροφορίες σχετικά ^f_handle:\n\n^url\n\n",
		'private_message_reply' => "Κάντε κλικ παρακάτω για να απαντήσετε στο ^f_handle με προσωπικό μήνυμα:\n\n^url\n\n",
		'private_message_subject' => 'Μήνυμα από ^f_handle σε ^site_title',

		'q_answered_body' => "Η ερώτησή σας στο ^site_title απαντήθηκε από τον χρήστη ^a_handle:\n\n^open^a_content^close\n\nΗ ερώτησή σας ήταν:\n\n^open^q_title^close\n\nΑν σας αρέσει αυτή η απάντηση μπορείτε να την επιλέξετε ως την καλύτερη:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'q_answered_subject' => 'Η ερώτησή σας στο ^site_title απαντήθηκε',

		'q_commented_body' => "Η ερώτησή σας στο ^site_title έχει ένα νέο σχόλιο από τον χρήστη ^c_handle:\n\n^open^c_content^close\n\nΗ ερώτησή σας ήταν:\n\n^open^c_context^close\n\nΜπορείτε να απαντήσετε προσθέτοντας το δικό σας σχόλιο:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'q_commented_subject' => 'Η ερώτησή σας στο ^site_title έχει ένα νέο σχόλιο',

		'q_posted_body' => "Μια νέα ερώτηση έγινε από τον χρήστη ^q_handle:\n\n^open^q_title\n\n^q_content^close\n\nΚάντε κλικ παρακάτω για να δείτε την ερώτηση:\n\n^url\n\nΕυχαριστούμε,\n\n^site_title",
		'q_posted_subject' => 'Η ^site_title έχει μια νέα ερώτηση',

		'reset_body' => "Παρακαλώ κάντε κλικ παρακάτω για να επαναφέρετε το password σας για το ^site_title.\n\n^url\n\nΕναλλακτικά, εισάγετε τον παρακάτω κωδικό στο αντίστοιχο πεδίο.\n\nΚωδικός: ^code\n\nΑν δε ζητήσατε επαναφορά του κωδικού σας, παρακαλούμε αγνοήστε αυτό το email.\n\nΕυχαριστούμε,\n^site_title",
		'reset_subject' => '^site_title - Επαναφορά ξεχασμένου password',

		'to_handle_prefix' => "^,\n\n",

		'welcome_body' => "Ευχαριστούμε για την εγγραφή σας στο ^site_title.\n\n^custom^confirmΤα στοιχεία σύνδεσή σας είναι τα ακόλουθα:\n\nEmail: ^email\nPassword: ^password\n\nΠαρακαλώ κρατήστε αυτή την πληροφορία ασφαλή για μελλοντική χρήση.\n\nΕυχαριστούμε,\n\n^site_title\n^url",
		'welcome_confirm' => "Παρακαλώ κάντε κλικ παρακάτω για να επιβεβαιώσετε τη διεύθυνση email.\n\n^url\n\n",
		'welcome_subject' => 'Καλώς Ήλθατε στο ^site_title!',
	);
	

/*
	Omit PHP closing tag to help avoid accidental output
*/