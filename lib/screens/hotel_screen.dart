import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../bloc/hotel_bloc.dart';
import '../services/service_api.dart';
import '../models/hotel.dart';
import '../screens/room_screen.dart';
import '../widgets/navigation_button.dart';
import '../widgets/image_carousel.dart';
import '../widgets/feature_list.dart';
import '../widgets/price_info.dart';
import '../widgets/rating_bar.dart';
import '../widgets/rounded_container.dart';
import '../utils/formatter.dart';

class HotelSceeen extends StatefulWidget {
  const HotelSceeen({super.key});

  @override
  State<HotelSceeen> createState() => _HotelSceeenState();
}

class _HotelSceeenState extends State<HotelSceeen> {
  final hotelBloc = HotelBloc(HotelsApi(Dio()));
  Hotel? hotel;

  @override
  void initState() {
    hotelBloc.add(LoadHotelEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Отель"))),
      backgroundColor: const Color(0xF0F6F6F9),
      body: BlocBuilder<HotelBloc, HotelState>(
          bloc: hotelBloc,
          builder: (context, state) {
            if (state is HotelLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HotelLoaded) {
              return _buildBody(hotel = state.hotel);
            }
            if (state is HotelError) {
              return const Center(child: Text('Ошибка сервера. Попробуйте позже.'));
            }
            return Container();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NavigationButton('К выбору номера', (_) => RoomScreen(hotel!))),
    );
  }

  Widget _buildBody(Hotel hotel) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedContainer(true, _buildTourDetails(hotel)),
          const SizedBox(height: 10),
          RoundedContainer(false, _buildHotelDetails(hotel)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTourDetails(Hotel hotel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ImageCarousel(hotel.imageUrls),
      const SizedBox(height: 10),
      RatingBar(hotel.rating, hotel.ratingName),
      const SizedBox(height: 5),
      Text(hotel.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Text(
        hotel.address,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0D72FF)),
      ),
      const SizedBox(height: 10),
      PriceInfo('От ${Formatter.formatMoney(hotel.minPrice)} ₽ ', hotel.priceInfo),
    ]);
  }

  Widget _buildHotelDetails(Hotel hotel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Об отеле', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      const SizedBox(height: 10),
      FeatureList(hotel.about.features),
      const SizedBox(height: 10),
      Text(
        hotel.about.description,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.9)),
      ),
      const SizedBox(height: 10),
      _buildWhatsIncluded(),
    ]);
  }

  Widget _buildWhatsIncluded() {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildWhatsIncludedTile(Icons.mood, 24, 'Удобства', 'Самое необходимое'),
        _buildWhatsIncludedTile(
            Icons.check_circle_outline, 24, 'Что включено', 'Самое необходимое'),
        _buildWhatsIncludedTile(Icons.highlight_off, 24, 'Что не включено', 'Самое необходимое'),
      ],
    );
  }

  ListTile _buildWhatsIncludedTile(IconData icon, double iconSize, String title, String subtitle) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -3),
      leading: Icon(icon, size: iconSize),
      title: Text(title,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2C3035))),
      subtitle: Text(subtitle,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF828796))),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF2C3035),
      ),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не реализовано.'),
          duration: Duration(seconds: 1),
        ),
      ),
    );
  }
}