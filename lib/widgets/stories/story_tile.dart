import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sohbetapp/core/services/story_service.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/models/profile_story.model.dart';
import 'package:sohbetapp/models/story_model.dart';
import 'package:sohbetapp/screens/stories/story_view.dart';
import 'package:sohbetapp/utilities/right_page_route.dart';

class StoryTile extends StatelessWidget {
  final List<ProfileAndStoryModel> profileAndStoryModel;
  final int index;

  const StoryTile({Key key, this.index, this.profileAndStoryModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Profile profile = profileAndStoryModel[index].profile;
    int length = profileAndStoryModel[index].stories.length;
    return profileAndStoryModel[index].stories.isEmpty
        ? ListTile(
            leading: DottedBorder(
              color: Colors.grey[400],
              dashPattern: [176 / length],
              borderType: BorderType.Circle,
              padding: EdgeInsets.all(5),
              strokeWidth: 3,
              child: CircleAvatar(
                child: CachedNetworkImage(imageUrl: profile.image),
              ),
            ),
            title: Text(profile.userName),
            subtitle: Text(profile.status),
          )
        : ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  SlideRightRoute(
                      page: StoryView(
                    index: index,
                    profileList: profileAndStoryModel,
                  )));
            },
            leading: DottedBorder(
              color: Theme.of(context).primaryColor,
              dashPattern: [double.infinity],
              borderType: BorderType.Circle,
              padding: EdgeInsets.all(3),
              strokeWidth: 2,
              child: CircleAvatar(
                backgroundImage: NetworkImage(profile.image),
              ),
            ),
            title: Text(profile.userName),
            subtitle: Text(profile.status),
          );
  }
}

class MainStoryTile extends StatelessWidget {
  final List<StoryModel> stories;
  final Profile profile;
  final int index;

  const MainStoryTile({Key key, this.stories, this.profile, this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    int length = stories.length;
    return stories.isEmpty
        ? ListTile(
            leading: DottedBorder(
              color: Colors.grey[400],
              dashPattern: [176 / length, (10 - length).toDouble()],
              borderType: BorderType.Circle,
              padding: EdgeInsets.all(5),
              strokeWidth: 3,
              child: CircleAvatar(
                backgroundImage: NetworkImage(profile.image),
              ),
            ),
            title: Text(profile.userName),
            subtitle: Text(profile.status),
          )
        : ListTile(
            onTap: () {
              List<ProfileAndStoryModel> profileAndStoryModel = [];
              profileAndStoryModel.add(ProfileAndStoryModel(profile, stories));
              Navigator.push(
                  context,
                  SlideRightRoute(
                      page: MainStoryView(
                    profileList: profileAndStoryModel,
                  )));
            },
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 0) {
                  StoryService service = StoryService();
                  service.deleteStories();
                }
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                    value: 0,
                    child: ListTile(
                      title: Text("Hikayeleri Temizle"),
                      leading: Icon(Icons.delete),
                    ))
              ],
            ),
            leading: DottedBorder(
              color: Theme.of(context).primaryColor,
              dashPattern: List<double>.generate(
                  length + 5,
                  (index) => index % 2 == 0
                      ? (180 / length).toDouble()
                      : (1 + length).toDouble()),
              borderType: BorderType.Circle,
              padding: EdgeInsets.all(3),
              strokeWidth: 2,
              child: CircleAvatar(
                backgroundImage: NetworkImage(profile.image),
              ),
            ),
            title: Text(profile.userName),
            subtitle: Text(profile.status),
          );
  }
}
