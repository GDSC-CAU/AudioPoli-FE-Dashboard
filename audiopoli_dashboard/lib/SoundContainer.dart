import 'package:flutter/cupertino.dart';
import './StyledContainer.dart';

class SoundContainer extends StatelessWidget {
  const SoundContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledContainer(
      widget: Container(
        child: Text("SoundContainer"),
      ),
    );
  }
}
