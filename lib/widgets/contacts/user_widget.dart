import 'package:flutter/material.dart';
import 'package:sohbetapp/models/models.dart';

class UserListTile extends StatelessWidget {
  final Profile profile;
  final Widget trailingWidget;
  const UserListTile({Key key, this.profile, this.trailingWidget})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profile.image),
      ),
      title: Text(profile.userName),
      subtitle: Text(profile.status),
      trailing: trailingWidget ??
          SizedBox(
            height: 3,
          ),
    );
  }
}
