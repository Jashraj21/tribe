import { Request, Response } from 'express';

// Seeded active Northeast experiences
const northeastEvents = [
  {
    id: 'pkg_meghalaya_roots',
    slug: 'mystical-meghalaya-living-root-bridges',
    title: 'Mystical Meghalaya & Living Root Bridges',
    subtitle: 'Waterfalls, crystal clear Dawki river & ancient root bridges',
    category: 'TRAVEL',
    city: 'Guwahati',
    venue: 'Guwahati Airport (GHY) Pickup',
    basePrice: 18999,
    badge: 'Bestseller • Flat ₹4,000 OFF',
    bannerUrl: 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62',
    duration: '6 Days / 5 Nights',
    rating: 4.95,
    availableCapacity: 12,
  },
  {
    id: 'pkg_kaziranga_rhino',
    slug: 'wild-assam-kaziranga-rhino-safari',
    title: 'Wild Assam: Kaziranga Rhino Safari & Majuli Island',
    subtitle: 'UNESCO World Heritage Rhino Safari & River Island Monasteries',
    category: 'TRAVEL',
    city: 'Guwahati',
    venue: 'Guwahati Airport (GHY) Pickup',
    basePrice: 16499,
    badge: 'Includes 2 Jeep + 1 Elephant Safari',
    bannerUrl: 'https://images.unsplash.com/photo-1534177616072-ef7dc120449d',
    duration: '5 Days / 4 Nights',
    rating: 4.92,
    availableCapacity: 8,
  },
  {
    id: 'concert_ziro_2026',
    slug: 'ziro-festival-of-music-2026',
    title: 'Ziro Festival of Music 2026',
    subtitle: 'Lucky Ali, Tetseo Sisters & Global Indie Acts',
    category: 'CONCERT',
    city: 'Itanagar',
    venue: 'Ziro Valley Pine Amphitheatre',
    basePrice: 4999,
    badge: 'FAST FILLING',
    bannerUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
    duration: '4 Days Festival Pass',
    rating: 4.98,
    availableCapacity: 45,
  },
  {
    id: 'concert_brahmaputra_summit',
    slug: 'brahmaputra-cultural-summit',
    title: 'Brahmaputra Cultural Summit',
    subtitle: 'Papon, Shankuraj Konwar & Friends',
    category: 'CONCERT',
    city: 'Guwahati',
    venue: 'Sarusajai Stadium Arena',
    basePrice: 1799,
    badge: 'EXCLUSIVE',
    bannerUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
    duration: '1 Evening',
    rating: 4.88,
    availableCapacity: 120,
  },
  {
    id: 'dine_terra_maya',
    slug: 'terra-maya-rooftop-lounge',
    title: 'Terra Maya Rooftop Lounge',
    subtitle: 'Craft Cocktails & Pan-Asian Grill with Brahmaputra Skyline',
    category: 'DINE_IN',
    city: 'Guwahati',
    venue: 'GS Road, Christian Basti',
    basePrice: 500, // Table reservation cover
    badge: '20% OFF TOTAL BILL',
    bannerUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
    rating: 4.85,
    availableCapacity: 6,
  },
];

export class EventsController {
  public getEvents = async (req: Request, res: Response) => {
    const { city, category } = req.query;

    let results = northeastEvents;
    if (city && typeof city === 'string') {
      const cleanCity = city.toLowerCase();
      results = results.filter((e) => e.city.toLowerCase().includes(cleanCity));
    }
    if (category && typeof category === 'string') {
      results = results.filter((e) => e.category.toLowerCase() === category.toLowerCase());
    }

    return res.status(200).json({
      success: true,
      count: results.length,
      data: results,
    });
  };

  public getEventById = async (req: Request, res: Response) => {
    const { id } = req.params;
    const event = northeastEvents.find((e) => e.id === id || e.slug === id);

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }
    return res.status(200).json({ success: true, data: event });
  };

  public getCities = async (_req: Request, res: Response) => {
    return res.status(200).json({
      success: true,
      data: [
        { city: 'Guwahati', state: 'Assam', isGateway: true, activeCount: 24 },
        { city: 'Shillong', state: 'Meghalaya', activeCount: 18 },
        { city: 'Itanagar', state: 'Arunachal Pradesh', activeCount: 12 },
        { city: 'Kohima', state: 'Nagaland', activeCount: 9 },
        { city: 'Imphal', state: 'Manipur', activeCount: 8 },
        { city: 'Aizawl', state: 'Mizoram', activeCount: 7 },
        { city: 'Agartala', state: 'Tripura', activeCount: 6 },
        { city: 'Gangtok', state: 'Sikkim', activeCount: 14 },
      ],
    });
  };
}
