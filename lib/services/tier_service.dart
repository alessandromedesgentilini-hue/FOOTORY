enum MatchTier { Tm2, Tm1, T0, Tp1, Tp2 }

class TierService {
  const TierService();

  MatchTier tier(double delta) {
    if (delta <= -25) return MatchTier.Tm2;
    if (delta <= -10) return MatchTier.Tm1;
    if (delta < 10) return MatchTier.T0;
    if (delta < 25) return MatchTier.Tp1;
    return MatchTier.Tp2;
  }
}
