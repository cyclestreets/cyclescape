class PlanningApplicationWorker
  # Update to use
  # http://planit.org.uk/find/areas/json
  LOCAL_AUTHORITIES = [
    'Aberdeen', 'Aberdeenshire', 'Adur', 'Adur and Worthing', 'Alderney', 'Allerdale', 'Amber Valley', 'Anglesey', 'Angus', 'Antrim',
    'Antrim and Newtownabbey', 'Ards', 'Ards and North Down', 'Argyll', 'Armagh', 'Armagh Banbridge Craigavon', 'Arun', 'Ashfield',
    'Ashford', 'Aylesbury Vale', 'Babergh', 'Ballymena', 'Ballymoney', 'Banbridge', 'Barking and Dagenham', 'Barnet', 'Barnsley', 'Barrow',
    'Basildon', 'Basingstoke', 'Bassetlaw', 'Bath', 'Bedford', 'Belfast', 'Bexley', 'Birmingham', 'Blaby', 'Blackburn', 'Blackpool',
    'Blaenau Gwent', 'Bolsover', 'Bolton', 'Boston', 'Bournemouth', 'Bracknell', 'Bradford', 'Braintree', 'Breckland', 'Brecon Beacons',
    'Brent', 'Brentwood', 'Bridgend', 'Brighton', 'Bristol', 'British Islands', 'Broadland', 'Broads', 'Bromley', 'Bromsgrove',
    'Broxbourne', 'Broxtowe', 'Buckinghamshire', 'Burnley', 'Bury', 'Caerphilly', 'Cairngorms', 'Calderdale', 'Cambridge',
    'Cambridgeshire', 'Camden', 'Cannock Chase', 'Canterbury', 'Cardiff', 'Carlisle', 'Carmarthenshire', 'Carrickfergus', 'Castle Point',
    'Castlereagh', 'Causeway and Glens', 'Central Bedfordshire', 'Ceredigion', 'Channel Islands', 'Charnwood', 'Chelmsford', 'Cheltenham',
    'Cherwell', 'Cheshire East', 'Chester', 'Chesterfield', 'Chichester', 'Chiltern', 'Chorley', 'Christchurch', 'City', 'Clackmannan',
    'Colchester', 'Coleraine', 'Conwy', 'Cookstown', 'Copeland', 'Corby', 'Cornwall', 'Cotswold', 'Coventry', 'Craigavon', 'Craven',
    'Crawley', 'Croydon', 'Cumbria', 'Dacorum', 'Darlington', 'Dartford', 'Dartmoor', 'Daventry', 'Denbighshire', 'Derby', 'Derbyshire',
    'Derbyshire Dales', 'Derry', 'Derry and Strabane', 'Devon', 'Doncaster', 'Dorset', 'Dover', 'Down', 'Dudley', 'Dumfries', 'Dundee',
    'Dungannon', 'Durham', 'Durham (Barnard Castle)', 'Durham (Chester-le-Street)', 'Durham (City)', 'Durham (Consett)', 'Durham (County)',
    'Durham (Crook)', 'Durham (Easington)', 'Durham (Sedgefield)', 'Ealing', 'East Ayr', 'East Cambridgeshire', 'East Devon', 'East Dorset',
    'East Dunbarton', 'East England', 'East Hampshire', 'East Hertfordshire', 'East Lindsey', 'East Lothian', 'East Midlands',
    'East Northamptonshire', 'East Renfrew', 'East Riding', 'East Staffordshire', 'East Sussex', 'East Wiltshire', 'Eastbourne',
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
    'Northumberland (Park)', 'Norwich', 'Nottingham', 'Nottinghamshire', 'Nuneaton', 'Oadby and Wigston', 'Oldham', 'Omagh', 'Orkney',
    'Oxford', 'Oxfordshire', 'Peak District', 'Pembroke Coast', 'Pembrokeshire', 'Pendle', 'Perth', 'Peterborough',
    'Planning Inspectorate', 'Plymouth', 'Poole', 'Portsmouth', 'Powys', 'Preston', 'Purbeck', 'Reading', 'Redbridge', 'Redcar and Cleveland',
    'Redditch', 'Reigate', 'Renfrew', 'Rhondda', 'Ribble Valley', 'Richmond', 'Richmondshire', 'Rochdale', 'Rochford', 'Rossendale',
    'Rother', 'Rotherham', 'Rugby', 'Runnymede', 'Rushcliffe', 'Rushmoor', 'Rutland', 'Ryedale', 'Salford', 'Sandwell', 'Sark',
    'Scarborough', 'Scilly Isles', 'Scotland', 'Scottish Borders', 'Sedgemoor', 'Sefton', 'Selby', 'Sevenoaks', 'Sheffield', 'Shepway',
    'Shetlands', 'Shropshire', 'Slough', 'Snowdonia', 'Solihull', 'Somerset', 'South Ayr', 'South Bucks', 'South Cambridgeshire',
    'South Derbyshire', 'South Downs', 'South East', 'South Gloucestershire', 'South Hams', 'South Holland', 'South Kesteven', 'South Lakeland',
    'South Lanark', 'South Norfolk', 'South Northamptonshire', 'South Oxfordshire', 'South Ribble', 'South Somerset',
    'South Staffordshire', 'South Tyneside', 'South West', 'South Wiltshire', 'South Yorkshire', 'Southampton', 'Southend', 'Southwark',
    'Spelthorne', 'St Albans', 'St Edmundsbury', 'St Helens', 'Stafford', 'Staffordshire', 'Staffordshire Moorlands', 'Stevenage',
    'Stirling', 'Stockport', 'Stockton-on-Tees', 'Stoke on Trent', 'Strabane', 'Stratford on Avon', 'Stroud', 'Suffolk', 'Suffolk Coastal',
    'Sunderland', 'Surrey', 'Surrey Heath', 'Sutton', 'Swale', 'Swansea', 'Swindon', 'Tameside', 'Tamworth', 'Tandridge', 'Taunton Deane',
    'Teignbridge', 'Telford', 'Tendring', 'Test Valley', 'Tewkesbury', 'Thanet', 'Three Rivers', 'Thurrock', 'Tonbridge', 'Torbay',
    'Torfaen', 'Torridge', 'Tower Hamlets', 'Trafford', 'Tunbridge Wells', 'Tyne and Wear', 'United Kingdom', 'Uttlesford',
    'Vale of White Horse', 'Wakefield', 'Wales', 'Walsall', 'Waltham Forest', 'Wandsworth', 'Warrington', 'Warwick', 'Warwickshire', 'Watford', 'Waveney',
    'Waverley', 'Wealden', 'Wellingborough', 'Welwyn Hatfield', 'West Berkshire', 'West Devon', 'West Dorset', 'West Dunbarton',
    'West Lancashire', 'West Lindsey', 'West Lothian', 'West Midlands', 'West Midlands County', 'West Oxfordshire', 'West Somerset',
    'West Suffolk', 'West Sussex', 'West Wiltshire', 'West Yorkshire', 'Western Isles', 'Westminster', 'Weymouth', 'Wigan', 'Wiltshire',
    'Winchester', 'Windsor', 'Wirral', 'Woking', 'Wokingham', 'Wolverhampton', 'Worcester', 'Worcestershire', 'Worthing', 'Wrexham',
    'Wychavon', 'Wycombe', 'Wyre', 'Wyre Forest', 'York', 'Yorkshire Dales', 'Yorkshire and Humber',
  ].freeze

  def initialize(end_date = (Date.today))
    @end_date = end_date
  end

  def process!
    new_planning_applications = LOCAL_AUTHORITIES.map do |la|
      get_authorty(la)
    end.flatten
    add_applications new_planning_applications
  end

  private

  def conn
    @conn ||= Excon.new(Rails.application.config.planning_applications_url, headers: { 'Accept' => Mime::JSON.to_s, 'Content-Type' => Mime::JSON.to_s })
  end

  def get_authorty(authority)
    total = JSON.load(conn.request(generate_authority_requests(authority)).body)
    if total['count'] == 500
      multi_total = (0..2).map do |days_offset|
        JSON.load(conn.request(generate_authority_requests(authority, days_offset)).body)
      end
      multi_total.map{ |resp| resp['records']}
    else
      total['records']
    end
  end

  def add_applications(planning_applications)
    PlanningApplication.transaction do
      planning_applications.each do |remote_pa|
        next unless remote_pa['uid'] && remote_pa['url']

        db_app = PlanningApplication.find_or_initialize_by uid: remote_pa['uid']
        [:address, :postcode, :description, :authority_name, :url, :start_date].each do |attr|
          db_app[attr] = remote_pa[attr.to_s]
        end
        db_app.location = "POINT(#{remote_pa['lng']} #{remote_pa['lat']})"
        db_app.save!
      end
    end
  end

  def generate_authority_requests(authority, days_offset = nil)
    dates = { start_date: (@end_date - 14.days), end_date: @end_date }

    if days_offset
      dates = { start_date: (@end_date - 14.days + (5 * days_offset).days),
                end_date:   (@end_date - 10.days + (5 * days_offset).days) }
    end

    {method: :get, idempotent: true, query:
     {auth: authority,
      start_date: dates[:start_date].to_s,
      end_date: dates[:end_date].to_s,
      pg_sz: 500, sort: '-start_date'}}
  end
end
