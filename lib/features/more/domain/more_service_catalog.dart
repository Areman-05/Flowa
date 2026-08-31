import 'package:flutter/material.dart';

class MoreProvider {
  const MoreProvider({
    required this.id,
    required this.name,
    required this.tone,
    this.initial,
  });

  final String id;
  final String name;
  final Color tone;
  final String? initial;
}

class MoreBillService {
  const MoreBillService({
    required this.title,
    required this.description,
    required this.referenceLabel,
    required this.referenceHint,
    required this.category,
    required this.providers,
  });

  final String title;
  final String description;
  final String referenceLabel;
  final String referenceHint;
  final String category;
  final List<MoreProvider> providers;
}

class MoreTicketEvent {
  const MoreTicketEvent({
    required this.title,
    required this.venue,
    required this.dateLabel,
    required this.priceFrom,
    required this.category,
  });

  final String title;
  final String venue;
  final String dateLabel;
  final double priceFrom;
  final String category;
}

class MoreInsurancePlan {
  const MoreInsurancePlan({
    required this.name,
    required this.summary,
    required this.monthly,
    required this.tone,
    required this.category,
    required this.coverages,
    this.deductible,
    this.waitingPeriod,
    this.highlights,
  });

  final String name;
  final String summary;
  final double monthly;
  final Color tone;
  final String category;
  final List<String> coverages;
  final String? deductible;
  final String? waitingPeriod;
  final List<String>? highlights;
}

class MoreDonationOrg {
  const MoreDonationOrg({
    required this.name,
    required this.summary,
    required this.tone,
    this.category,
  });

  final String name;
  final String summary;
  final Color tone;
  final String? category;
}

class MoreBranch {
  const MoreBranch({
    required this.name,
    required this.address,
    required this.hours,
    required this.distanceKm,
    this.services,
  });

  final String name;
  final String address;
  final String hours;
  final double distanceKm;
  final List<String>? services;
}

class MoreCurrency {
  const MoreCurrency({
    required this.code,
    required this.name,
    required this.rate,
    required this.symbol,
    required this.flag,
  });

  final String code;
  final String name;
  final double rate;
  final String symbol;
  final String flag;
}

abstract final class MoreServiceCatalog {
  static const mobile = MoreBillService(
    title: 'Móvil',
    description: 'Recarga saldo o paga tu factura de operador.',
    referenceLabel: 'Número de móvil',
    referenceHint: '600 000 000',
    category: 'Recarga',
    providers: [
      MoreProvider(id: 'movistar', name: 'Movistar', tone: Color(0xFF00A9E0)),
      MoreProvider(id: 'vodafone', name: 'Vodafone', tone: Color(0xFFE60000)),
      MoreProvider(id: 'orange', name: 'Orange', tone: Color(0xFFFF7900)),
      MoreProvider(id: 'yoigo', name: 'Yoigo', tone: Color(0xFF7B2CBF)),
    ],
  );

  static const utilities = MoreBillService(
    title: 'Suministros',
    description: 'Luz, agua y gas desde tu cuenta Flowa.',
    referenceLabel: 'Referencia / CUPS',
    referenceHint: 'ES 0021 4023 ...',
    category: 'Servicios',
    providers: [
      MoreProvider(id: 'endesa', name: 'Endesa', tone: Color(0xFF005BAC)),
      MoreProvider(id: 'naturgy', name: 'Naturgy', tone: Color(0xFFE87722)),
      MoreProvider(id: 'agua', name: 'Canal de Isabel II', tone: Color(0xFF0072BC)),
      MoreProvider(id: 'repsol', name: 'Repsol Luz', tone: Color(0xFFFF8200)),
    ],
  );

  static const internet = MoreBillService(
    title: 'Internet',
    description: 'Fibra, ADSL y datos móviles.',
    referenceLabel: 'N.º de contrato',
    referenceHint: 'CNT-284910',
    category: 'Servicios',
    providers: [
      MoreProvider(id: 'movistar', name: 'Movistar', tone: Color(0xFF00A9E0)),
      MoreProvider(id: 'vodafone', name: 'Vodafone', tone: Color(0xFFE60000)),
      MoreProvider(id: 'orange', name: 'Orange', tone: Color(0xFFFF7900)),
      MoreProvider(id: 'digi', name: 'Digi', tone: Color(0xFF0066CC)),
    ],
  );

  static const tv = MoreBillService(
    title: 'TV',
    description: 'Plataformas y paquetes de televisión.',
    referenceLabel: 'Usuario o contrato',
    referenceHint: 'usuario@email.com',
    category: 'Ocio',
    providers: [
      MoreProvider(id: 'movistar', name: 'Movistar+', tone: Color(0xFF00A9E0)),
      MoreProvider(id: 'netflix', name: 'Netflix', tone: Color(0xFFE50914)),
      MoreProvider(id: 'dazn', name: 'DAZN', tone: Color(0xFFFFFA00), initial: 'D'),
      MoreProvider(id: 'filmin', name: 'Filmin', tone: Color(0xFF00E6A6)),
    ],
  );

  static const tickets = <MoreTicketEvent>[
    MoreTicketEvent(
      title: 'Indie Gijón Festival',
      venue: 'Plaza Mayor',
      dateLabel: '12 Sep · 21:00',
      priceFrom: 18,
      category: 'Conciertos',
    ),
    MoreTicketEvent(
      title: 'Love of Lesbian',
      venue: 'Kursaal · San Sebastián',
      dateLabel: '20 Sep · 20:30',
      priceFrom: 42,
      category: 'Conciertos',
    ),
    MoreTicketEvent(
      title: 'Dua Lipa · Radical Optimism',
      venue: 'WiZink Center · Madrid',
      dateLabel: '28 Sep · 21:00',
      priceFrom: 65,
      category: 'Conciertos',
    ),
    MoreTicketEvent(
      title: 'Real Madrid vs Barça',
      venue: 'Cinesa · Oviedo',
      dateLabel: 'Dom 19:30',
      priceFrom: 9.5,
      category: 'Cine',
    ),
    MoreTicketEvent(
      title: 'Oppenheimer (IMAX)',
      venue: 'Yelmo · Gijón',
      dateLabel: 'Vie 22:00',
      priceFrom: 11.5,
      category: 'Cine',
    ),
    MoreTicketEvent(
      title: 'Festival de Cine de San Sebastián',
      venue: 'Kursaal',
      dateLabel: '18–26 Sep',
      priceFrom: 8,
      category: 'Cine',
    ),
    MoreTicketEvent(
      title: 'Sporting - Racing',
      venue: 'El Molinón',
      dateLabel: '28 Sep · 18:30',
      priceFrom: 24,
      category: 'Deporte',
    ),
    MoreTicketEvent(
      title: 'Real Oviedo - Zaragoza',
      venue: 'Carlos Tartiere',
      dateLabel: '5 Oct · 16:15',
      priceFrom: 18,
      category: 'Deporte',
    ),
    MoreTicketEvent(
      title: 'La Vuelta · Etapa Oviedo',
      venue: 'Circuito urbano',
      dateLabel: '8 Sep · 14:00',
      priceFrom: 0,
      category: 'Deporte',
    ),
    MoreTicketEvent(
      title: 'Teatro Campoamor',
      venue: 'Oviedo',
      dateLabel: '5 Oct · 20:00',
      priceFrom: 32,
      category: 'Teatro',
    ),
    MoreTicketEvent(
      title: 'El médico de su honra',
      venue: 'Teatro Jovellanos · Gijón',
      dateLabel: '15 Oct · 19:00',
      priceFrom: 22,
      category: 'Teatro',
    ),
    MoreTicketEvent(
      title: 'Stand-up · Eva Soriano',
      venue: 'Palacio de Congresos',
      dateLabel: '22 Oct · 21:30',
      priceFrom: 28,
      category: 'Comedia',
    ),
    MoreTicketEvent(
      title: 'Festival Internacional del Humor',
      venue: 'Avilés',
      dateLabel: '3 Nov · 20:00',
      priceFrom: 15,
      category: 'Comedia',
    ),
  ];

  static const insurance = <MoreInsurancePlan>[
    MoreInsurancePlan(
      name: 'Salud autónomos',
      summary: 'Copago bajo y cobertura dental básica.',
      monthly: 58.9,
      tone: Color(0xFFCC7888),
      category: 'Salud',
      deductible: '150 €/año',
      waitingPeriod: 'Sin carencia en urgencias',
      coverages: [
        'Medicina general y especialistas',
        'Urgencias 24 h',
        'Dental básica (2 limpiezas/año)',
        'Pruebas diagnósticas',
        'Hospitalización sin copago',
      ],
      highlights: ['Recomendado para freelance', 'Sin permanencia'],
    ),
    MoreInsurancePlan(
      name: 'Salud familiar',
      summary: 'Pareja e hijos con pediatría incluida.',
      monthly: 112.4,
      tone: Color(0xFF9A7EC8),
      category: 'Salud',
      deductible: '200 €/año',
      waitingPeriod: '6 meses parto',
      coverages: [
        'Pediatría y vacunas',
        'Ginecología y obstetricia',
        'Fisioterapia (10 sesiones/año)',
        'Psicología (6 sesiones/año)',
        'Óptica 150 €/año',
      ],
    ),
    MoreInsurancePlan(
      name: 'Responsabilidad civil',
      summary: 'Protección profesional para consultoría.',
      monthly: 14.5,
      tone: Color(0xFF7A94D4),
      category: 'Profesional',
      deductible: '300 € por siniestro',
      coverages: [
        'RC profesional hasta 300.000 €',
        'Defensa jurídica incluida',
        'Daños a terceros en visitas',
        'Ciberriesgos básicos',
        'Indemnización por paralización',
      ],
      highlights: ['Imprescindible si facturas servicios'],
    ),
    MoreInsurancePlan(
      name: 'Accidentes laborales',
      summary: 'Invalidez y baja por accidente en trabajo.',
      monthly: 9.8,
      tone: Color(0xFF6890B8),
      category: 'Profesional',
      coverages: [
        'Invalidez permanente',
        'Indemnización diaria por baja',
        'Gastos de rehabilitación',
        'Capital por fallecimiento',
      ],
    ),
    MoreInsurancePlan(
      name: 'Hogar esencial',
      summary: 'Continente y contenido en alquiler.',
      monthly: 11.2,
      tone: Color(0xFFA07058),
      category: 'Hogar',
      deductible: '100 €',
      coverages: [
        'Continente hasta 80.000 €',
        'Contenido hasta 25.000 €',
        'Robo con fuerza',
        'Daños por agua',
        'Responsabilidad familiar',
      ],
    ),
    MoreInsurancePlan(
      name: 'Hogar premium',
      summary: 'Electrodomésticos, joyas y asistencia 24 h.',
      monthly: 24.9,
      tone: Color(0xFFCC9168),
      category: 'Hogar',
      deductible: '50 €',
      coverages: [
        'Todo riesgo contenido',
        'Electrodomésticos hasta 5 años',
        'Asistencia cerrajería y fontanería',
        'Alquiler alternativo 6 meses',
        'RC hasta 600.000 €',
      ],
    ),
    MoreInsurancePlan(
      name: 'Vida básica',
      summary: 'Capital para tu familia si faltas.',
      monthly: 7.5,
      tone: Color(0xFF6DB892),
      category: 'Vida',
      coverages: [
        'Capital 50.000 €',
        'Doble capital por accidente',
        'Anticipo por enfermedad grave',
        'Sin reconocimiento médico hasta 100.000 €',
      ],
    ),
    MoreInsurancePlan(
      name: 'Mascotas',
      summary: 'Perros y gatos con veterinario incluido.',
      monthly: 19.9,
      tone: Color(0xFFC4A060),
      category: 'Otros',
      deductible: '50 €/año',
      coverages: [
        'Consultas veterinarias',
        'Vacunas y desparasitación',
        'Cirugías hasta 2.000 €',
        'Responsabilidad civil mascota',
      ],
    ),
  ];

  static const donations = <MoreDonationOrg>[
    MoreDonationOrg(
      name: 'Cruz Roja',
      summary: 'Emergencias y ayuda social.',
      tone: Color(0xFFE60000),
      category: 'Emergencias',
    ),
    MoreDonationOrg(
      name: 'UNICEF',
      summary: 'Infancia y educación.',
      tone: Color(0xFF00AEEF),
      category: 'Infancia',
    ),
    MoreDonationOrg(
      name: 'Banco de Alimentos',
      summary: 'Comida para familias vulnerables.',
      tone: Color(0xFF6DB892),
      category: 'Social',
    ),
    MoreDonationOrg(
      name: 'Fundación Emplea',
      summary: 'Inserción laboral joven.',
      tone: Color(0xFF9A7EC8),
      category: 'Empleo',
    ),
    MoreDonationOrg(
      name: 'Médicos Sin Fronteras',
      summary: 'Atención sanitaria en crisis.',
      tone: Color(0xFFE87722),
      category: 'Salud',
    ),
    MoreDonationOrg(
      name: 'Greenpeace',
      summary: 'Protección del medio ambiente.',
      tone: Color(0xFF4CAF50),
      category: 'Medio ambiente',
    ),
    MoreDonationOrg(
      name: 'Amnistía Internacional',
      summary: 'Derechos humanos en todo el mundo.',
      tone: Color(0xFFFFD700),
      category: 'Derechos',
    ),
    MoreDonationOrg(
      name: 'Cáritas',
      summary: 'Apoyo a personas en exclusión.',
      tone: Color(0xFF005BAC),
      category: 'Social',
    ),
    MoreDonationOrg(
      name: 'Fundación Aladina',
      summary: 'Niños con cáncer y sus familias.',
      tone: Color(0xFFFF6B9D),
      category: 'Salud',
    ),
    MoreDonationOrg(
      name: 'WWF España',
      summary: 'Conservación de especies y hábitats.',
      tone: Color(0xFF2E7D32),
      category: 'Medio ambiente',
    ),
  ];

  static const branches = <MoreBranch>[
    MoreBranch(
      name: 'Flowa · Gijón Centro',
      address: 'C/ Langreo, 23',
      hours: 'L–V 9:00–18:00',
      distanceKm: 0.8,
      services: ['Caja', 'Asesoría', 'Préstamos'],
    ),
    MoreBranch(
      name: 'Flowa · Gijón Arena',
      address: 'Av. de la Costa, 12',
      hours: 'L–S 10:00–20:00',
      distanceKm: 2.1,
      services: ['Caja', 'Tarjetas'],
    ),
    MoreBranch(
      name: 'Flowa · Oviedo',
      address: 'Av. de la Universidad, 4',
      hours: 'L–V 9:00–17:30',
      distanceKm: 28,
      services: ['Caja', 'Asesoría', 'Seguros'],
    ),
    MoreBranch(
      name: 'Flowa · Oviedo Los Prados',
      address: 'C.C. Los Prados, planta 1',
      hours: 'L–S 10:00–21:00',
      distanceKm: 29.5,
      services: ['Caja', 'Atención express'],
    ),
    MoreBranch(
      name: 'Flowa · Avilés',
      address: 'Plaza España, 2',
      hours: 'Mar–Jue 10:00–14:00',
      distanceKm: 12,
      services: ['Caja', 'Préstamos'],
    ),
    MoreBranch(
      name: 'Flowa · Avilés Milán',
      address: 'C/ Milán, 8',
      hours: 'L–V 9:00–14:00',
      distanceKm: 12.4,
      services: ['Caja'],
    ),
    MoreBranch(
      name: 'Flowa · Mieres',
      address: 'C/ La Vega, 45',
      hours: 'L–V 9:00–14:00',
      distanceKm: 18,
      services: ['Caja', 'Asesoría autónomos'],
    ),
    MoreBranch(
      name: 'Flowa · Langreo',
      address: 'C/ La Felguera, 3',
      hours: 'L–V 9:00–15:00',
      distanceKm: 8.5,
      services: ['Caja'],
    ),
    MoreBranch(
      name: 'Flowa · Madrid Castellana',
      address: 'Paseo de la Castellana, 89',
      hours: 'L–V 9:00–18:00',
      distanceKm: 470,
      services: ['Caja', 'Asesoría', 'Empresas'],
    ),
  ];

  static const currencies = <MoreCurrency>[
    MoreCurrency(code: 'EUR', name: 'Euro', rate: 1, symbol: '€', flag: '🇪🇺'),
    MoreCurrency(code: 'USD', name: 'Dólar USA', rate: 1.08, symbol: '\$', flag: '🇺🇸'),
    MoreCurrency(code: 'GBP', name: 'Libra esterlina', rate: 0.86, symbol: '£', flag: '🇬🇧'),
    MoreCurrency(code: 'CHF', name: 'Franco suizo', rate: 0.94, symbol: 'CHF', flag: '🇨🇭'),
    MoreCurrency(code: 'JPY', name: 'Yen japonés', rate: 162.5, symbol: '¥', flag: '🇯🇵'),
    MoreCurrency(code: 'CAD', name: 'Dólar canadiense', rate: 1.47, symbol: 'C\$', flag: '🇨🇦'),
    MoreCurrency(code: 'AUD', name: 'Dólar australiano', rate: 1.65, symbol: 'A\$', flag: '🇦🇺'),
    MoreCurrency(code: 'MXN', name: 'Peso mexicano', rate: 18.2, symbol: 'MX\$', flag: '🇲🇽'),
    MoreCurrency(code: 'PLN', name: 'Zloty polaco', rate: 4.32, symbol: 'zł', flag: '🇵🇱'),
    MoreCurrency(code: 'SEK', name: 'Corona sueca', rate: 11.4, symbol: 'kr', flag: '🇸🇪'),
    MoreCurrency(code: 'NOK', name: 'Corona noruega', rate: 11.6, symbol: 'kr', flag: '🇳🇴'),
    MoreCurrency(code: 'BRL', name: 'Real brasileño', rate: 5.35, symbol: 'R\$', flag: '🇧🇷'),
  ];

  static Map<String, double> get exchangeRates => {
        for (final c in currencies) c.code: c.rate,
      };
}
