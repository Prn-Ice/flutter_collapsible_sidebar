// ignore_for_file: member-ordering-extended
library collapsible_sidebar;

import 'dart:math' as math show pi;

import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_avatar.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_container.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item_selection.dart';
import 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item_widget.dart';
import 'package:flutter/material.dart';

export 'package:collapsible_sidebar/collapsible_sidebar/collapsible_item.dart';

class CollapsibleSidebar extends StatefulWidget {
  const CollapsibleSidebar({
    Key? key,
    required this.items,
    this.title = 'Lorem Ipsum',
    this.titleStyle,
    this.titleBack = false,
    this.titleBackIcon = Icons.arrow_back,
    this.onHoverPointer = SystemMouseCursors.click,
    this.textStyle,
    this.toggleTitleStyle,
    this.toggleTitle = 'Collapse',
    this.avatarImg,
    this.height = double.infinity,
    this.minWidth = 80,
    this.maxWidth = 270,
    this.borderRadius = 15,
    this.iconSize = 40,
    this.toggleButtonIcon = Icons.chevron_right,
    this.backgroundColor = const Color(0xff2B3138),
    this.selectedIconBox = const Color(0xff2F4047),
    this.selectedIconColor = const Color(0xff4AC6EA),
    this.selectedTextColor = const Color(0xffF3F7F7),
    this.unselectedIconColor = const Color(0xff6A7886),
    this.unselectedTextColor = const Color(0xffC0C7D0),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastLinearToSlowEaseIn,
    this.screenPadding = 4,
    this.showToggleButton = true,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.fitItemsToBottom = false,
    required this.body,
    this.onTitleTap,
    this.isCollapsed = true,
    this.sidebarBoxShadow = const [
      BoxShadow(
        color: Colors.blue,
        blurRadius: 10,
        spreadRadius: 0.01,
        offset: Offset(3, 3),
      ),
    ],
    this.onToggleButtonTap,
  }) : super(key: key);

  final String title, toggleTitle;
  final MouseCursor onHoverPointer;
  final TextStyle? titleStyle, textStyle, toggleTitleStyle;
  final bool titleBack;
  final IconData titleBackIcon;
  final Widget body;
  final ImageProvider<Object>? avatarImg;
  final bool showToggleButton, fitItemsToBottom, isCollapsed;
  final List<CollapsibleItem> items;
  final double height,
      minWidth,
      maxWidth,
      borderRadius,
      iconSize,
      // ignore: avoid_field_initializers_in_const_classes
      padding = 10,
      // ignore: avoid_field_initializers_in_const_classes
      itemPadding = 10,
      topPadding,
      bottomPadding,
      screenPadding;
  final IconData toggleButtonIcon;
  final Color backgroundColor,
      selectedIconBox,
      selectedIconColor,
      selectedTextColor,
      unselectedIconColor,
      unselectedTextColor;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTitleTap;
  final void Function(bool)? onToggleButtonTap;
  final List<BoxShadow> sidebarBoxShadow;

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late CurvedAnimation _curvedAnimation;
  late double tempWidth;

  late bool _isCollapsed;
  late double _currentWidth,
      _delta,
      _delta1By4,
      _delta3by4,
      _maxOffsetX,
      _maxOffsetY;
  late int _selectedItemIndex;

  @override
  void initState() {
    assert(widget.items.isNotEmpty, 'Items cannot be empty');

    super.initState();

    tempWidth = widget.maxWidth > 270 ? 270 : widget.maxWidth;

    _currentWidth = widget.minWidth;
    _delta = tempWidth - widget.minWidth;
    _delta1By4 = _delta * 0.25;
    _delta3by4 = _delta * 0.75;
    _maxOffsetX = widget.padding * 2 + widget.iconSize;
    _maxOffsetY = widget.itemPadding * 2 + widget.iconSize;
    for (var i = 0; i < widget.items.length; i++) {
      if (!widget.items[i].isSelected) continue;
      _selectedItemIndex = i;
      break;
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _controller.addListener(() {
      _currentWidth = _widthAnimation.value;
      if (_controller.isCompleted) {
        _isCollapsed = _currentWidth == widget.minWidth;
      }
      setState(() {});
    });

    _isCollapsed = widget.isCollapsed;
    final endWidth = _isCollapsed ? widget.minWidth : tempWidth;
    _animateTo(endWidth);
  }

  void _animateTo(double endWidth) {
    _widthAnimation = Tween<double>(
      begin: _currentWidth,
      end: endWidth,
    ).animate(_curvedAnimation);
    _controller
      ..reset()
      ..forward();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      _currentWidth += details.primaryDelta!;
      if (_currentWidth > tempWidth) {
        _currentWidth = tempWidth;
      } else if (_currentWidth < widget.minWidth) {
        _currentWidth = widget.minWidth;
      } else {
        setState(() {});
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails _) {
    if (_currentWidth == tempWidth) {
      setState(() => _isCollapsed = false);
    } else if (_currentWidth == widget.minWidth) {
      setState(() => _isCollapsed = true);
    } else {
      final threshold = _isCollapsed ? _delta1By4 : _delta3by4;
      final endWidth = _currentWidth - widget.minWidth > threshold
          ? tempWidth
          : widget.minWidth;
      _animateTo(endWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.minWidth * 1.1),
          child: widget.body,
        ),
        Padding(
          padding: EdgeInsets.all(widget.screenPadding),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: CollapsibleContainer(
              height: widget.height,
              width: _currentWidth,
              padding: widget.padding,
              borderRadius: widget.borderRadius,
              color: widget.backgroundColor,
              sidebarBoxShadow: widget.sidebarBoxShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatar,
                  SizedBox(height: widget.topPadding),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      reverse: widget.fitItemsToBottom,
                      child: Stack(
                        children: [
                          CollapsibleItemSelection(
                            height: _maxOffsetY,
                            offsetY: _maxOffsetY * _selectedItemIndex,
                            color: widget.selectedIconBox,
                            duration: widget.duration,
                            curve: widget.curve,
                          ),
                          Column(children: _items),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: widget.bottomPadding),
                  if (widget.showToggleButton)
                    Divider(
                      color: widget.unselectedIconColor,
                      indent: 5,
                      endIndent: 5,
                      thickness: 1,
                    )
                  else
                    const SizedBox(height: 5),
                  if (widget.showToggleButton)
                    _toggleButton
                  else
                    SizedBox(height: widget.iconSize),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get _avatar {
    return CollapsibleItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: widget.itemPadding,
      offsetX: _offsetX,
      scale: _fraction,
      leading: widget.titleBack
          ? Icon(
              widget.titleBackIcon,
              size: widget.iconSize,
              color: widget.unselectedIconColor,
            )
          : CollapsibleAvatar(
              backgroundColor: widget.unselectedIconColor,
              avatarSize: widget.iconSize,
              name: widget.title,
              avatarImg: widget.avatarImg,
              textStyle: _textStyle(widget.backgroundColor, widget.titleStyle),
            ),
      title: widget.title,
      textStyle: _textStyle(widget.unselectedTextColor, widget.titleStyle),
      onTap: widget.onTitleTap,
    );
  }

  List<Widget> get _items {
    return List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      var iconColor = widget.unselectedIconColor;
      var textColor = widget.unselectedTextColor;
      if (item.isSelected) {
        iconColor = widget.selectedIconColor;
        textColor = widget.selectedTextColor;
      }
      return CollapsibleItemWidget(
        onHoverPointer: widget.onHoverPointer,
        padding: widget.itemPadding,
        offsetX: _offsetX,
        scale: _fraction,
        leading: Icon(
          item.icon,
          size: widget.iconSize,
          color: iconColor,
        ),
        title: item.text,
        textStyle: _textStyle(textColor, widget.textStyle),
        onTap: () {
          if (item.isSelected) return;
          item.onPressed();
          item.isSelected = true;
          widget.items[_selectedItemIndex].isSelected = false;
          setState(() => _selectedItemIndex = index);
        },
      );
    });
  }

  Widget get _toggleButton {
    return CollapsibleItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: widget.itemPadding,
      offsetX: _offsetX,
      scale: _fraction,
      leading: Transform.rotate(
        angle: _currentAngle,
        child: Icon(
          widget.toggleButtonIcon,
          size: widget.iconSize,
          color: widget.unselectedIconColor,
        ),
      ),
      title: widget.toggleTitle,
      textStyle:
          _textStyle(widget.unselectedTextColor, widget.toggleTitleStyle),
      onTap: () {
        _isCollapsed = !_isCollapsed;
        widget.onToggleButtonTap?.call(_isCollapsed);
        final endWidth = _isCollapsed ? widget.minWidth : tempWidth;
        _animateTo(endWidth);
      },
    );
  }

  double get _fraction => (_currentWidth - widget.minWidth) / _delta;
  double get _currentAngle => -math.pi * _fraction;
  double get _offsetX => _maxOffsetX * _fraction;

  TextStyle _textStyle(Color color, TextStyle? style) {
    return style == null
        ? TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          )
        : style.copyWith(color: color);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
