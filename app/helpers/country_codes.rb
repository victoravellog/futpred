module CountryCodes
  # Banderas especiales de subdivisiones (Inglaterra, Escocia, Gales)
  SUBDIVISION_FLAGS = {
    "ENG" => "🏴󠁧󠁢󠁥󠁮󠁧󠁿",
    "SCO" => "🏴󠁧󠁢󠁳󠁣󠁴󠁿",
    "WAL" => "🏴󠁧󠁢󠁷󠁬󠁳󠁿",
    "NIR" => "🇬🇧"
  }.freeze

  OBSOLETE_CODES = {
    "AN" => "CW"
  }.freeze

  ALPHA3_TO_ALPHA2 = {
    "CUW" => "CW", "CUR" => "CW",
    "AFG" => "AF", "ALB" => "AL", "ALG" => "DZ", "DZA" => "DZ", "AND" => "AD", "AGO" => "AO",
    "ARG" => "AR", "ARM" => "AM", "AUS" => "AU", "AUT" => "AT", "AZE" => "AZ",
    "BHR" => "BH", "BGD" => "BD", "BLR" => "BY", "BEL" => "BE", "BEN" => "BJ",
    "BOL" => "BO", "BIH" => "BA", "BRA" => "BR", "BGR" => "BG", "CMR" => "CM",
    "CAN" => "CA", "CHL" => "CL", "CHN" => "CN", "COL" => "CO", "CRI" => "CR",
    "HRV" => "HR", "CUB" => "CU", "CYP" => "CY", "CZE" => "CZ", "DNK" => "DK",
    "DOM" => "DO", "ECU" => "EC", "EGY" => "EG", "SLV" => "SV", "ENG" => "GB",
    "EST" => "EE", "ETH" => "ET", "FIN" => "FI", "FRA" => "FR", "GEO" => "GE",
    "DEU" => "DE", "GHA" => "GH", "GRC" => "GR", "GTM" => "GT", "HND" => "HN",
    "HUN" => "HU", "ISL" => "IS", "IND" => "IN", "IDN" => "ID", "IRN" => "IR",
    "IRQ" => "IQ", "IRL" => "IE", "ISR" => "IL", "ITA" => "IT", "JAM" => "JM",
    "JPN" => "JP", "JOR" => "JO", "KAZ" => "KZ", "KEN" => "KE", "KOR" => "KR",
    "KWT" => "KW", "LVA" => "LV", "LBN" => "LB", "LTU" => "LT", "LUX" => "LU",
    "MKD" => "MK", "MYS" => "MY", "MLI" => "ML", "MLT" => "MT", "MEX" => "MX",
    "MDA" => "MD", "MNE" => "ME", "MAR" => "MA", "NLD" => "NL", "NZL" => "NZ",
    "NGA" => "NG", "NIR" => "GB", "NOR" => "NO", "OMN" => "OM", "PAN" => "PA",
    "PRY" => "PY", "PER" => "PE", "PHL" => "PH", "POL" => "PL", "PRT" => "PT",
    "QAT" => "QA", "ROU" => "RO", "RUS" => "RU", "SAU" => "SA", "SCO" => "GB",
    "SEN" => "SN", "SRB" => "RS", "SGP" => "SG", "SVK" => "SK", "SVN" => "SI",
    "ZAF" => "ZA", "ESP" => "ES", "SWE" => "SE", "CHE" => "CH", "THA" => "TH",
    "TUN" => "TN", "TUR" => "TR", "UKR" => "UA", "ARE" => "AE", "GBR" => "GB",
    "USA" => "US", "URY" => "UY", "UZB" => "UZ", "VEN" => "VE", "VNM" => "VN",
    "WAL" => "GB", "YEM" => "YE", "ZMB" => "ZM", "ZWE" => "ZW", "CIV" => "CI",
    "COD" => "CD", "CPV" => "CV", "CRC" => "CR", "HKG" => "HK", "TWN" => "TW",
    "SUI" => "CH", "RSA" => "ZA", "KSA" => "SA", "CRO" => "HR", "NED" => "NL",
    "POR" => "PT", "GER" => "DE", "SLO" => "SI"
  }.freeze

  def self.to_alpha2(code)
    return nil if code.blank?
    return code if code.length == 2
    ALPHA3_TO_ALPHA2[code.upcase] || code[0..1]
  end

  def self.to_flag(code)
    return nil if code.blank?
    upper = code.upcase

    # Banderas especiales de subdivisiones
    return SUBDIVISION_FLAGS[upper] if SUBDIVISION_FLAGS.key?(upper)

    # Convertir códigos obsoletos
    upper = OBSOLETE_CODES[upper] if OBSOLETE_CODES.key?(upper)

    # Convertir a alpha2 si es necesario
    alpha2 = upper.length == 2 ? upper : ALPHA3_TO_ALPHA2[upper]
    return nil unless alpha2

    # Generar emoji de bandera
    alpha2.chars.map { |c| (c.ord + 0x1F1A5).chr(Encoding::UTF_8) }.join
  end
end
