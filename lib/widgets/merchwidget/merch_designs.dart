import 'package:cliff/screens/Merch/merch_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/right_to_left_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class MerchDesigns extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> isForDisplayList;
  const MerchDesigns({
    super.key,
    required this.isForDisplayList,
  });

  @override
  State<MerchDesigns> createState() => _MerchDesignsState();
}

class _MerchDesignsState extends State<MerchDesigns> {
  late List<bool> isLikedList;

  @override
  void initState() {
    super.initState();
    isLikedList =
        List.generate(widget.isForDisplayList.length, (index) => false);
    loadLikes();
  }

  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  Future<void> loadLikes() async {
    for (int i = 0; i < widget.isForDisplayList.length; i++) {
      DocumentSnapshot documentSnapshot = widget.isForDisplayList[i];
      DocumentReference docRef = documentSnapshot.reference;
      DocumentSnapshot merchSnapshot = await docRef.get();
      var likes = merchSnapshot['likes'] as List?;
      if (likes != null && likes.contains(currentUser)) {
        setState(() {
          isLikedList[i] = true;
        });
      }
    }
  }

  // Future<void> _updateUserLikedProducts(String userId, String productId) async {
  //   final userQuery = await FirebaseFirestore.instance
  //       .collection("users")
  //       .where("userid", isEqualTo: userId)
  //       .get();

  //   for (var docSnapshot in userQuery.docs) {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(docSnapshot.id)
  //         .update({
  //       'likedproducts': FieldValue.arrayUnion([productId]),
  //     });
  //   }
  // }

  Future<void> _updateUserLikedProducts(
      String userId, String productId, bool isLiked) async {
    final userQuery = await FirebaseFirestore.instance
        .collection("users")
        .where("userid", isEqualTo: userId)
        .get();

    for (var docSnapshot in userQuery.docs) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(docSnapshot.id);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('likedproducts')) {
          List<String> likedProducts = userSnapshot['likedproducts'] != null
              ? List<String>.from(userSnapshot['likedproducts'])
              : [];

          if (isLiked) {
            if (!likedProducts.contains(productId)) {
              likedProducts.add(productId);
              await userDocRef.update({'likedproducts': likedProducts});
            }
          } else {
            if (likedProducts.contains(productId)) {
              likedProducts.remove(productId);
              await userDocRef.update({'likedproducts': likedProducts});
            }
          }
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docSnapshot.id)
              .update({
            'likedproducts': FieldValue.arrayUnion([productId]),
          });
        }
      }
    }
  }

  Future<void> toggleLike(int index) async {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot documentSnapshot = widget.isForDisplayList[index];
    DocumentReference docRef = documentSnapshot.reference;
    DocumentSnapshot merchSnapshot = await docRef.get();
    var likes = merchSnapshot['likes'] as List?;

    bool isLiked = likes != null && likes.contains(currentUser);

    // Update merchandise document's likes field
    if (isLiked) {
      likes.remove(currentUser);
    } else {
      likes ??= [];
      likes.add(currentUser);
    }
    await docRef.set({'likes': likes}, SetOptions(merge: true));

    // Update user's document with liked product ID and isLiked value
    await _updateUserLikedProducts(currentUser, docRef.id, !isLiked);

    setState(() {
      isLikedList[index] = !isLikedList[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final font20 = screenHeight * 0.02;
    int itemCount = widget.isForDisplayList.length;
    return itemCount > 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Design Showcase",
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: font20,
                    fontWeight: FontWeight.bold,
                    // color: textColor,
                  ),
                ),
              ),
              GridView.builder(
                itemCount: itemCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7, // 1.41
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  // mainAxisExtent: 280,
                ),
                itemBuilder: (context, index) {
                  final merchData = widget.isForDisplayList[index];
                  String merchName = merchData['productname'];
                  String merchImage = merchData['image_url'];
                  return InkWell(
                    //navigate to merch details screen
                    onTap: () {
                      Navigator.of(context).push(PageAnimationTransition(
                        page: MerchDetails(
                          merchName: merchName,
                          merchPrice: int.parse(merchData['productprice']),
                          merchDesc: merchData['productdescription'],
                          photoUrl: merchImage,
                          isForSale: false,
                          merchId: merchData.id.toString(),
                        ),
                        pageAnimationType: RightToLeftFadedTransition(),
                      ));
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
                        children: [
                          Container(
                            height: screenHeight * 0.18,
                            width: double.infinity,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(
                                    merchImage), // fetch from backend
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            merchName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: font20,
                              fontWeight: FontWeight.bold,
                              // color: textColor,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              toggleLike(index);
                            },
                            icon: isLikedList[index]
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                  )
                                : const Icon(Icons.favorite_border),
                            label: Text(
                                '${widget.isForDisplayList[index]['likes'].length} Likes'),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
              ),
            ],
          )
        : const SizedBox();
  }
}
