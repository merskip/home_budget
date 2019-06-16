import 'package:flutter/material.dart';


class BudgetFlexibleSpaceBar extends StatelessWidget {

  final Widget subtitle;
  final Widget title;

  BudgetFlexibleSpaceBar({Key key, this.subtitle, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final subtitleStyle = Theme.of(context).primaryTextTheme.body1.copyWith(fontSize: 14);
    final titleStyle = Theme.of(context).primaryTextTheme.title.copyWith(fontSize: 26);

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: subtitleStyle,
              child: subtitle
            ),
            SizedBox(height: 4),
            DefaultTextStyle(
              style: titleStyle,
              child: title
            )
          ]
        )
      ),
    );
  }

}