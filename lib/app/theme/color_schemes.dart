import 'package:flutter/material.dart';

class AppColors {
  // ===== DEFAULT =====
  static const Color defaultColor = Color(0xFF292822);
  static const Color default0 = Color(0xFFFFFFFF);
  static const Color default10 = Color(0xFFFBFBFA);
  static const Color default20 = Color(0xFFF8F8F6);
  static const Color default30 = Color(0xFFF5F5F1);
  static const Color default40 = Color(0xFFEDEDE8);
  static const Color default50 = Color(0xFFE2E1DB);
  static const Color default60 = Color(0xFFC3C2BD);
  static const Color default70 = Color(0xFF9F9E99);
  static const Color default80 = Color(0xFF6D6D6A);
  static const Color default90 = Color(0xFF37352F);

  // ===== PRIMARY =====
  static const Color primary = Color(0xFF724CDA);
  static const Color primary10 = Color(0xFFF2EEFC);
  static const Color primary20 = Color(0xFFE4DDF8);
  static const Color primary30 = Color(0xFFD6CCF5);
  static const Color primary40 = Color(0xFFC9BBF2);
  static const Color primary50 = Color(0xFFBCAAEE);
  static const Color primary60 = Color(0xFFAF99EA);
  static const Color primary70 = Color(0xFFA288E7);
  static const Color primary80 = Color(0xFF9478E3);
  static const Color primary90 = Color(0xFF8767E0);

  // ===== SECONDARY =====
  static const Color secondary = Color(0xFF34324C);
  static const Color secondary10 = Color(0xFFAAA9C7);
  static const Color secondary20 = Color(0xFF9E9CBF);
  static const Color secondary30 = Color(0xFF9290B6);
  static const Color secondary40 = Color(0xFF8684AE);
  static const Color secondary50 = Color(0xFF6E6B9E);
  static const Color secondary60 = Color(0xFF646194);
  static const Color secondary70 = Color(0xFF54517B);
  static const Color secondary80 = Color(0xFF4C496F);
  static const Color secondary90 = Color(0xFF434063);

  // ===== DANGER =====
  static const Color danger = Color(0xFFE14747);
  static const Color danger10 = Color(0xFFFCEDED);
  static const Color danger20 = Color(0xFFFADCDC);
  static const Color danger30 = Color(0xFFF7CACA);
  static const Color danger40 = Color(0xFFF4B8B8);
  static const Color danger50 = Color(0xFFF1A7A7);
  static const Color danger60 = Color(0xFFEE9696);
  static const Color danger70 = Color(0xFFEB8484);
  static const Color danger80 = Color(0xFFE87373);
  static const Color danger90 = Color(0xFFE56161);

  // ===== INFO =====
  static const Color info = Color(0xFF2A88F4);
  static const Color info10 = Color(0xFFD8E9FD);
  static const Color info20 = Color(0xFFC5DFFC);
  static const Color info30 = Color(0xFFB1D4FB);
  static const Color info40 = Color(0xFF9EC9FA);
  static const Color info50 = Color(0xFF8BBEF9);
  static const Color info60 = Color(0xFF77B3F8);
  static const Color info70 = Color(0xFF64A9F7);
  static const Color info80 = Color(0xFF519EF6);
  static const Color info90 = Color(0xFF3D93F5);

  // ===== SUCCESS =====
  static const Color success = Color(0xFF40C58B);
  static const Color success10 = Color(0xFFD0F1E2);
  static const Color success20 = Color(0xFFC1ECD9);
  static const Color success30 = Color(0xFFB1E7D0);
  static const Color success40 = Color(0xFFA2E2C6);
  static const Color success50 = Color(0xFF92DDBD);
  static const Color success60 = Color(0xFF82D9B3);
  static const Color success70 = Color(0xFF73D4AA);
  static const Color success80 = Color(0xFF63CFA0);
  static const Color success90 = Color(0xFF53CA97);

  // ===== WARNING =====
  static const Color warning = Color(0xFFF9BB00);
  static const Color warning10 = Color(0xFFFFF0C2);
  static const Color warning20 = Color(0xFFFFEBAD);
  static const Color warning30 = Color(0xFFFFE699);
  static const Color warning40 = Color(0xFFFFE085);
  static const Color warning50 = Color(0xFFFFDB70);
  static const Color warning60 = Color(0xFFFFD65C);
  static const Color warning70 = Color(0xFFFFD147);
  static const Color warning80 = Color(0xFFFFCC33);
  static const Color warning90 = Color(0xFFFFC71F);

  // ===== ATTENTION =====
  static const Color attention = Color(0xFFFF8403);
  static const Color attention10 = Color(0xFFFFE1C2);
  static const Color attention20 = Color(0xFFFFD8AD);
  static const Color attention30 = Color(0xFFFFCE99);
  static const Color attention40 = Color(0xFFFFC485);
  static const Color attention50 = Color(0xFFFFBA70);
  static const Color attention60 = Color(0xFFFFB05C);
  static const Color attention70 = Color(0xFFFFA647);
  static const Color attention80 = Color(0xFFFF9C33);
  static const Color attention90 = Color(0xFFFF931F);

  // ===== GRAY / OTHERS =====
  static const Color agentMessageColor = Color(0xFF6B5EBB);
  static const Color quoteColorOutgoing = Color(0xFF5B4FA2);
  static const Color gray = Color(0xFF4F5663);
}

/// Global gradient definitions converted from SCSS :root
class AppGradients {
  static const RadialGradient gradientPrimary = RadialGradient(
    center: Alignment(0.125, 1.0),
    radius: 1.23,
    colors: [Color(0xFF805AF0), Color(0xFF775BD4), Color(0xFF685DA5)],
    stops: [0.0, 0.54, 1.0],
  );

  static const RadialGradient gradientInfo = RadialGradient(
    center: Alignment(0.0595, 0.8361),
    radius: 1.06,
    colors: [Color(0xFF2A88F4), Color(0xFF64A9F7)],
    stops: [0.09, 1.0],
  );

  static const RadialGradient gradientSuccess = RadialGradient(
    center: Alignment(1.0635, 0.8033),
    radius: 1.01,
    colors: [Color(0xFF92DDBD), Color(0xFF40C58B)],
  );

  static const RadialGradient gradientDanger = RadialGradient(
    center: Alignment(0.0873, 0.7131),
    radius: 1.05,
    colors: [Color(0xFFE14747), Color(0xFFFF8403)],
  );

  static const RadialGradient gradientAttention = RadialGradient(
    center: Alignment(0.0913, 0.7623),
    radius: 0.98,
    colors: [Color(0xFFFF8403), Color(0xFFFFBA70)],
  );

  static const RadialGradient gradientWarning = RadialGradient(
    center: Alignment(0.0992, 0.7623),
    radius: 0.97,
    colors: [Color(0xFFF9BB00), Color(0xFFFFDB70)],
  );

  static const RadialGradient gradientFbMessenger = RadialGradient(
    center: Alignment(0.1925, 0.9945),
    radius: 1.09,
    colors: [
      Color(0xFF0099FF),
      Color(0xFFA033FF),
      Color(0xFFFF5280),
      Color(0xFFFF7061),
    ],
    stops: [0.0, 0.6098, 0.9348, 1.0],
  );

  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7A5BDD), Color(0xFF6C5DB1)],
  );

  static const RadialGradient gradientInstagram = RadialGradient(
    center: Alignment(-0.4, 1.07),
    radius: 1.0,
    colors: [
      Color(0xFFFDF497),
      Color(0xFFFDF497),
      Color(0xFFFd5949),
      Color(0xFFD6249F),
      Color(0xFF285AEB),
    ],
    stops: [0.0, 0.05, 0.45, 0.6, 0.9],
  );

  static const LinearGradient gradientZalo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0068FF), Color(0xFF005EE6)],
  );

  static const LinearGradient gradientWhatsapp = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF25D366), Color(0xFF00BFA5)],
  );
}
