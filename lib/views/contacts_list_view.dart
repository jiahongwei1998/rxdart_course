import 'package:flutter/material.dart';
import 'package:rxdart_course/dialogs/delete_contact_dialog.dart';
import 'package:rxdart_course/models/contact.dart';
import 'package:rxdart_course/type_definitions.dart';
import 'package:rxdart_course/views/main_popup_menu_button.dart';

class ContactsListView extends StatelessWidget {
  final LogoutCallback logout;
  final DeleteAccountCallback deleteAccount;
  final DeleteContactCallback deleteContact;
  final VoidCallback createNewContact;
  final Stream<Iterable<Contact>> contacts;

  const ContactsListView({
    super.key,
    required this.logout,
    required this.deleteAccount,
    required this.deleteContact,
    required this.createNewContact,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
        actions: [
          MainPopupMenuButton(logout: logout, deleteAccount: deleteAccount),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewContact,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<Iterable<Contact>>(
        stream: contacts,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              final contacts = snapshot.requireData;
              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts.elementAt(index);
                  return ContactListTile(
                    contact: contact,
                    deleteContact: deleteContact,
                  );
                },
              );
          }
        },
      ),
    );
  }
}

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final DeleteContactCallback deleteContact;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.deleteContact,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.firstName),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final shouldDelete = await showDeleteContactDialog(context: context);
          if (shouldDelete) {
            deleteContact(contact);
          }
        },
      ),
    );
  }
}
