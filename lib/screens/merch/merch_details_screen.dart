import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchDetails extends StatefulWidget {
  static const routeName = '/merch-details';

  final String merchName;
  final int merchPrice;
  final String merchDesc;
  final String photoUrl;
  final bool isForSale;

  const MerchDetails({
    super.key,
    required this.merchName,
    required this.merchPrice,
    required this.merchDesc,
    required this.photoUrl,
    required this.isForSale,
  });

  @override
  State<MerchDetails> createState() => _MerchDetailsState();
}

class _MerchDetailsState extends State<MerchDetails> {
  List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  late List<bool> selectedSizes;
  bool isLiked = false;
  bool isItemInCart = false;

  @override
  void initState() {
    super.initState();
    selectedSizes = List<bool>.generate(sizes.length, (index) => false);
    checkIfItemInCart();
  }

  Future<void> checkIfItemInCart() async {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    final userQuery = await FirebaseFirestore.instance
        .collection("users")
        .where("userid", isEqualTo: currentUser)
        .get();

    for (var docSnapshot in userQuery.docs) {
      Map<String, dynamic> data = docSnapshot.data();
      if (data.containsKey('cart')) {
        Map<String, dynamic> userCart = data['cart'] as Map<String, dynamic>;
        if (userCart.containsKey(widget.merchName)) {
          setState(() {
            isItemInCart = true;
          });
          return; // No need to continue checking once we find the item
        }
      }
    }

    setState(() {
      isItemInCart = false;
    });
  }

  Future<void> _updateUserCart(
    String userId,
    String productId,
    int quantity,
    String selectedSize,
  ) async {
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
        if (data.containsKey('cart')) {
          Map<String, dynamic> userCart =
              userSnapshot['cart'] as Map<String, dynamic>;

          if (userCart.containsKey(productId)) {
            // Update existing item's quantity in cart
            int currentQuantity = userCart[productId]['quantity'] as int;
            int newQuantity = currentQuantity + quantity;
            userCart[productId]['quantity'] = newQuantity;
            userCart[productId]['size'] = selectedSize;
          } else {
            // Add new item to cart
            userCart[productId] = {
              'quantity': quantity,
              'size': selectedSize,
            };
          }

          await userDocRef.update({'cart': userCart});
        } else {
          // Initialize cart and add the first item
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docSnapshot.id)
              .set({
            'cart': {
              productId: {
                'quantity': quantity,
                'size': selectedSize,
              }
            },
          }, SetOptions(merge: true));
        }
      }
    }
  }

  Future<void> addToCart(
      String productId, int quantity, String selectedSize) async {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    await _updateUserCart(currentUser, productId, quantity, selectedSize);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final font30 = screenHeight * 0.035;
    final font18 = screenHeight * 0.02;

    //List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
    //List<bool> selectedSizes = [false, false, false, false, false];
    void handleChipSelection(int selectedIndex) {
      setState(() {
        for (int i = 0; i < selectedSizes.length; i++) {
          if (selectedSizes[i] == true) {
            selectedSizes[i] = false;
          } else {
            if (i == selectedIndex) {
              selectedSizes[i] = true;
            } else {
              selectedSizes[i] = false;
            }
          }
        }
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(
              "Merch Details",
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontWeight: FontWeight.bold,
                // color: textColor,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  null;
                },
                icon: const Icon(Icons.shopping_cart),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //event image container, this will not change (probably)
                  Container(
                      height: screenHeight * 0.4,
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          //REPLACE THIS WITH THE ACTUAL PHOTO URL later
                          image: NetworkImage(widget.photoUrl),
                          fit: BoxFit.cover,
                        ),
                      )),

                  const SizedBox(
                    height: 20,
                  ),

                  //Designs
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.merchName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: font30,
                            fontWeight: FontWeight.bold,
                            // color: textColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "₹${widget.merchPrice}",
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: font30,
                                fontWeight: FontWeight.bold,
                                // color: textColor,
                              ),
                            ),
                            const Spacer(),

                            // //like button
                            // !widget.isForSale ? FilterChip(
                            //   label: const Text(
                            //     '24 likes',
                            //   ),
                            //   showCheckmark: false,
                            //   avatar: Icon(
                            //     isLiked ? Icons.favorite : Icons.favorite_border,
                            //     color: Colors.red,
                            //   ),
                            //   selected: isLiked,
                            //   onSelected: (bool selected) {
                            //     setState(() {
                            //       isLiked = selected;
                            //     });
                            //   },
                            // ) : const SizedBox(),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.isForSale
                            ? const Text(
                                "Sizes",
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  // color: textColor,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.isForSale
                            ? Wrap(
                                spacing: 10,
                                children: List<Widget>.generate(
                                  sizes.length,
                                  (int index) {
                                    return ChoiceChip(
                                      label: Text(
                                        sizes[index],
                                        style: const TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      selected: selectedSizes[index],
                                      onSelected: (bool selected) {
                                        handleChipSelection(index);
                                      },
                                    );
                                  },
                                ).toList(),
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // color: textColor,
                          ),
                        ),
                        Text(
                          widget.merchDesc,
                          style: TextStyle(
                            fontSize: font18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isForSale
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // color: textColor,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FilledButton(
                      child: Text(
                        isItemInCart ? "in Cart" : "Add to cart",
                        style: const TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // color: textColor,
                        ),
                      ),
                      onPressed: () async {
                        int selectedSizeIndex = selectedSizes.indexOf(true);

                        if (selectedSizeIndex != -1) {
                          String selectedSize = sizes[selectedSizeIndex];

                          await addToCart(widget.merchName, 1, selectedSize);

                          setState(() {
                            isItemInCart =
                                true; // Update the state to indicate the item was added
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Select a Size'),
                                content: const Text(
                                    'Please select a size before adding to cart.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
