# frozen_string_literal: true

class PlanningFilter < ActiveRecord::Base
  LOCAL_AUTHORITIES = [
    'Aberdeen', 'Aberdeenshire', 'Adur', 'Adur and Worthing', 'Alderney', 'Allerdale', 'Amber Valley', 'Anglesey', 'Angus', 'Antrim',
    'Antrim and Newtownabbey', 'Ards', 'Ards and North Down', 'Argyll', 'Armagh', 'Armagh Banbridge Craigavon', 'Arun', 'Ashfield',
    'Ashford', 'Aylesbury Vale', 'Babergh', 'Babergh Mid Suffolk', 'Ballymena', 'Ballymoney', 'Banbridge', 'Barking and Dagenham', 'Barnet', 'Barnsley', 'Barrow',
    'Basildon', 'Basingstoke', 'Bassetlaw', 'Bath', 'Bedford', 'Belfast', 'Bexley', 'Birmingham', 'Blaby', 'Blackburn', 'Blackpool',
    'Blaenau Gwent', 'Bolsover', 'Bolton', 'Boston', 'Bournemouth', 'Bracknell', 'Bradford', 'Braintree', 'Breckland', 'Brecon Beacons',
    'Brent', 'Brentwood', 'Bridgend', 'Brighton', 'Bristol', 'British Islands', 'Broadland', 'Broads', 'Bromley', 'Bromsgrove',
    'Bromsgrove Redditch', 'Broxbourne', 'Broxtowe', 'Buckinghamshire', 'Burnley', 'Bury', 'Caerphilly', 'Cairngorms', 'Calderdale', 'Cambridge',
    'Cambridgeshire', 'Camden', 'Cannock Chase', 'Canterbury', 'Cardiff', 'Carlisle', 'Carmarthenshire', 'Carrickfergus', 'Castle Point',
    'Castlereagh', 'Causeway and Glens', 'Central Bedfordshire', 'Ceredigion', 'Channel Islands', 'Charnwood', 'Chelmsford', 'Cheltenham',
    'Cherwell', 'Cheshire East', 'Chester', 'Chesterfield', 'Chichester', 'Chiltern', 'Chorley', 'Christchurch', 'City', 'Clackmannan',
    'Colchester', 'Coleraine', 'Conwy', 'Cookstown', 'Copeland', 'Corby', 'Cornwall', 'Cotswold', 'Coventry', 'Craigavon', 'Craven',
    'Crawley', 'Croydon', 'Cumbria', 'Dacorum', 'Darlington', 'Dartford', 'Dartmoor', 'Daventry', 'Denbighshire', 'Derby', 'Derbyshire',
    'Derbyshire Dales', 'Derry', 'Derry and Strabane', 'Devon', 'Doncaster', 'Dorset', 'Dover', 'Down', 'Dudley', 'Dumfries', 'Dundee',
    'Dungannon', 'Durham', 'Durham (Barnard Castle)', 'Durham (Chester-le-Street)', 'Durham (City)', 'Durham (Consett)', 'Durham (County)',
    'Durham (Crook)', 'Durham (Easington)', 'Durham (Sedgefield)', 'Ealing', 'East Ayr', 'East Cambridgeshire', 'East Devon', 'East Dorset',
    'East Dunbarton', 'East England', 'East Hampshire', 'East Hertfordshire', 'East Lindsey', 'East Lothian', 'East Midlands',
    'East Northamptonshire', 'East Renfrew', 'East Riding', 'East Staffordshire', 'East Suffolk', 'East Sussex', 'East Wiltshire', 'Eastbourne',
    'Eastleigh', 'Eden', 'Edinburgh', 'Elmbridge', 'Enfield', 'England', 'England and Wales', 'Epping Forest', 'Epsom and Ewell',
    'Erewash', 'Essex', 'Exeter', 'Exmoor', 'Falkirk', 'Fareham', 'Fenland', 'Fermanagh', 'Fermanagh and Omagh', 'Fife', 'Flintshire',
    'Forest Heath', 'Forest of Dean', 'Fylde', 'Gateshead', 'Gedling', 'Glamorgan', 'Glasgow', 'Gloucester', 'Gloucestershire', 'Gosport',
    'Gravesham', 'Great Britain', 'Great Yarmouth', 'Greater Manchester', 'Greenwich', 'Guernsey', 'Guernsey Bailiwick', 'Guildford',
    'Gwynedd', 'Hackney', 'Halton', 'Hambleton', 'Hammersmith and Fulham', 'Hampshire', 'Harborough', 'Haringey', 'Harlow', 'Harrogate',
    'Harrow', 'Hart', 'Hartlepool', 'Hastings', 'Havant', 'Havering', 'Herefordshire', 'Hertfordshire', 'Hertsmere', 'High Peak',
    'Highland', 'Hillingdon', 'Hinckley and Bosworth', 'Horsham', 'Hounslow', 'Hull', 'Huntingdonshire', 'Hyndburn', 'Inverclyde',
    'Ipswich', 'Isle of Man', 'Isle of Wight', 'Islington', 'Jersey', 'Kensington', 'Kent', 'Kettering', 'Kings Lynn', 'Kingston',
    'Kirklees', 'Knowsley', 'Lake District', 'Lambeth', 'Lancashire', 'Lancaster', 'Larne', 'Leeds', 'Leicester', 'Leicestershire',
    'Lewes', 'Lewisham', 'Lichfield', 'Limavady', 'Lincoln', 'Lincolnshire', 'Lisburn', 'Lisburn and Castlereagh', 'Liverpool', 'Loch Lomond',
    'London', 'London Legacy', 'Luton', 'Magherafelt', 'Maidstone', 'Maldon', 'Malvern Hills', 'Manchester', 'Mansfield',
    'Medway', 'Melton', 'Mendip', 'Merseyside', 'Merthyr Tydfil', 'Merton', 'Mid Devon', 'Mid East Antrim', 'Mid Kent', 'Mid Suffolk',
    'Mid Sussex', 'Mid Ulster', 'Middlesbrough', 'Midlothian', 'Milton Keynes', 'Mole Valley', 'Monmouthshire', 'Moray', 'Moyle', 'Neath',
    'New Forest (District)', 'New Forest (Park)', 'Newark and Sherwood', 'Newcastle under Lyme', 'Newcastle upon Tyne', 'Newham', 'Newport',
    'Newry Mourne Down', 'Newry and Mourne', 'Newtownabbey', 'Norfolk', 'North Ayr', 'North Devon', 'North Dorset', 'North Down',
    'North East', 'North East Derbyshire', 'North East Lincs', 'North Hertfordshire', 'North Kesteven', 'North Lanark', 'North Lincs',
    'North Norfolk', 'North Somerset', 'North Tyneside', 'North Warwickshire', 'North West', 'North West Leicestershire', 'North Wiltshire',
    'North York Moors', 'North Yorkshire', 'Northampton', 'Northamptonshire', 'Northern Ireland', 'Northumberland (County)',
    'Northumberland (Park)', 'Norwich', 'Nottingham', 'Nottinghamshire', 'Nuneaton', 'Oadby and Wigston', 'Oldham', 'Olympics', 'Omagh', 'Orkney',
    'Oxford', 'Oxfordshire', 'Peak District', 'Pembroke Coast', 'Pembrokeshire', 'Pendle', 'Perth', 'Peterborough',
    'Planning Inspectorate', 'Plymouth', 'Poole', 'Portsmouth', 'Powys', 'Preston', 'Purbeck', 'Reading', 'Redbridge', 'Redcar and Cleveland',
    'Redditch', 'Reigate', 'Renfrew', 'Rhondda', 'Ribble Valley', 'Richmond', 'Richmondshire', 'Rochdale', 'Rochford', 'Rossendale',
    'Rother', 'Rotherham', 'Rugby', 'Runnymede', 'Rushcliffe', 'Rushmoor', 'Rutland', 'Ryedale', 'Salford', 'Sandwell', 'Sark',
    'Scarborough', 'Scilly Isles', 'Scotland', 'Scottish Borders', 'Sedgemoor', 'Sefton', 'Selby', 'Sevenoaks', 'Sheffield', 'Shepway',
    'Shetlands', 'Shropshire', 'Slough', 'Snowdonia', 'Solihull', 'Somerset', 'South Ayr', 'South Bucks', 'South Cambridgeshire',
    'South Derbyshire', 'South Downs', 'South East', 'South Gloucestershire', 'South Hams', 'South Holland', 'South Kesteven', 'South Lakeland',
    'South Lanark', 'South Norfolk', 'South Northamptonshire', 'South Oxfordshire', 'South Ribble', 'South Somerset',
    'South Staffordshire', 'South Tyneside', 'South West', 'South West Devon', 'South Wiltshire', 'South Yorkshire', 'Southampton', 'Southend', 'Southwark',
    'Spelthorne', 'St Albans', 'St Edmundsbury', 'St Helens', 'Stafford', 'Staffordshire', 'Staffordshire Moorlands', 'Stevenage',
    'Stirling', 'Stockport', 'Stockton-on-Tees', 'Stoke on Trent', 'Strabane', 'Stratford on Avon', 'Stroud', 'Suffolk', 'Suffolk Coastal',
    'Sunderland', 'Surrey', 'Surrey Heath', 'Sutton', 'Swale', 'Swansea', 'Swindon', 'Tameside', 'Tamworth', 'Tandridge', 'Taunton Deane',
    'Teignbridge', 'Telford', 'Tendring', 'Test Valley', 'Tewkesbury', 'Thames Gateway', 'Thanet', 'Three Rivers', 'Thurrock', 'Tonbridge', 'Torbay',
    'Torfaen', 'Torridge', 'Tower Hamlets', 'Trafford', 'Tunbridge Wells', 'Tyne and Wear', 'United Kingdom', 'Uttlesford',
    'Vale of White Horse', 'Wakefield', 'Wales', 'Walsall', 'Waltham Forest', 'Wandsworth', 'Warrington', 'Warwick', 'Warwickshire', 'Watford', 'Waveney', 'Waverley',
    'Wealden', 'Wellingborough', 'Welwyn Hatfield', 'West Berkshire', 'West Devon', 'West Dorset', 'West Dunbarton',
    'West Lancashire', 'West Lindsey', 'West Lothian', 'West Midlands', 'West Midlands County', 'West Oxfordshire', 'West Somerset',
    'West Suffolk', 'West Sussex', 'West Wiltshire', 'West Yorkshire', 'Western Isles', 'Westminster', 'Weymouth', 'Wigan', 'Wiltshire',
    'Winchester', 'Windsor', 'Wirral', 'Woking', 'Wokingham', 'Wolverhampton', 'Worcester', 'Worcestershire', 'Worthing', 'Wrexham',
    'Wychavon', 'Wycombe', 'Wyre', 'Wyre Forest', 'York', 'Yorkshire Dales', 'Yorkshire and Humber'
  ].freeze

  STAR = '* (LAs without own rules)'.freeze

  validates :authority, inclusion: { in: LOCAL_AUTHORITIES + [STAR] }
  validate :ensure_rule_is_valid_regex

  after_save :update_relevancies

  def matches?(planning_application)
    if (authority == STAR && self.class.where(authority: planning_application.authority_name).blank?) ||
        planning_application.authority_name == authority
      return Regexp.new(rule).match(planning_application.uid)
    end
    false
  end

  private

  def update_relevancies
    Resque.enqueue(SearchUpdater, :update_relevant_planning_applications)
  end

  def ensure_rule_is_valid_regex
    return unless rule
    Regexp.new rule
  rescue => e
    errors.add(:rule, e.message)
  end

end
