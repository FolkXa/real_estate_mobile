import 'package:flutter/material.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import '../core/app_export.dart';

// ignore_for_file: must_be_immutable
class CustomPhoneNumber extends StatelessWidget {
  CustomPhoneNumber({
    Key? key,
    required this.country,
    required this.onTap,
    required this.controller,
  }) : super(key: key);

  final Country? country;
  final Function(Country) onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(
          color: appTheme.blueGray50,
          width: 1.h,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.gray3003d,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              _openCountryPicker(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: appTheme.blueGray50,
                  width: 1.h,
                ),
              ),
              child: Row(
                children: [
                  CountryPickerUtils.getDefaultFlagImage(country!),
                  SizedBox(width: 8.h),
                  Text(
                    "+${country!.phoneCode}",
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: 240.h,
              margin: EdgeInsets.only(left: 10.h),
              child: TextFormField(
                focusNode: FocusNode(),
                autofocus: true,
                controller: controller,
                style: theme.textTheme.titleSmall,
                decoration: InputDecoration(
                  hintText: "lbl_phone_number".tr,
                  hintStyle: theme.textTheme.titleSmall,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.h,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              country.name,
              style: TextStyle(fontSize: 14.fSize),
            ),
          ),
        ],
      );

  void _openCountryPicker(BuildContext context) => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          searchInputDecoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(fontSize: 14.fSize),
          ),
          isSearchable: true,
          title: Text(
            'Select your phone code',
            style: TextStyle(fontSize: 14.fSize),
          ),
          onValuePicked: (Country country) => onTap(country),
          itemBuilder: _buildDialogItem,
        ),
      );
}

