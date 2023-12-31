import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/Events/event_details_screen.dart';

class UpComingEventsWidgets extends StatelessWidget {
  const UpComingEventsWidgets({
    super.key,
    required this.upcomingEvents,
    required this.screenHeight,
    required this.font24,
  });

  final List<QueryDocumentSnapshot<Object?>> upcomingEvents;
  final double screenHeight;
  final double font24;
  final start = 100;
  @override
  Widget build(BuildContext context) {
    return upcomingEvents.isNotEmpty ? GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingEvents.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.41,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final eventData = upcomingEvents[index];
        Timestamp eventStartDateTimeStamp = eventData['eventstartdatetime'];
        String eventStartDate =
            DateFormat('dd-MM-yyyy').format(eventStartDateTimeStamp.toDate());

        return FadeIn(
          duration: Duration(milliseconds: start * (index+1)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(
                    title: eventData['eventname'],
                    eventCode: eventData['eventcode'],
                    eventDescription: eventData['eventdescription'],
                    eventFinishDateTime: eventData['eventfinishdatetime'],
                    eventImage: eventData['image_url'],
                    eventStartDateTime: eventData['eventstartdatetime'],
                    eventVenue: eventData['eventVenue'],
                    clubMembersic1: eventData['clubmembersic1'],
                    clubMembersic2: eventData['clubmembersic2'],
                    // should also contain description to display it dynamically
                    // and also the event code to match and display information related to this event
                    // basically pass everything needed literally everything.
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenHeight * 0.165,
                    width: double.infinity,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(
                          eventData['image_url'],
                        ), // should be dynamic
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      eventData['eventname'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: font24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        // color: textColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.group,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Theme.of(context).colorScheme.outline,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            "200 Registered", // should be dynamic
                            style: TextStyle(
                              fontSize: 18,
                              // color: textColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          label: Text(
                            eventStartDate,
                            // should date dynamically and the date should
                          ),
                          avatar: const Icon(Icons.today),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) : const Center(child: Text("No Upcoming Events", style: TextStyle(height: 2.5),),);
  }
}
