demo_user = User.find_or_initialize_by(email: "example.user@example.com")
demo_user.assign_attributes(
  password: "examplepassword",
  password_confirmation: "examplepassword",
  default_calendar_view: "month",
  default_upcoming_days: 7
)
demo_user.save!

# Keep seed runs predictable: preserve the account, but rebuild its example calendar.
demo_user.event_series.destroy_all
demo_user.events.destroy_all

today = Date.current
current_month = today.beginning_of_month
next_month = current_month.next_month
seed_start = [ today.beginning_of_week(:monday), current_month ].min
seed_end = next_month.end_of_month

def time_on(date, hour, minute = 0)
  Time.zone.local(date.year, date.month, date.day, hour, minute)
end

def create_event!(user, date:, title:, starts:, ends_at:, color:, description:, location: nil, all_day: false, series: nil)
  starts_at = all_day ? date.beginning_of_day : time_on(date, *starts)
  event_ends_at = all_day ? date.end_of_day : time_on(date, *ends_at)

  user.events.create!(
    title: title,
    description: description,
    location: location,
    starts_at: starts_at,
    ends_at: event_ends_at,
    all_day: all_day,
    color: color,
    event_series: series
  )
end

def next_matching_date(start_date, target_wday)
  start_date + ((target_wday - start_date.wday) % 7).days
end

weekly_templates = [
  {
    wday: 1,
    title: "Weekly planning review",
    starts: [ 9, 0 ],
    ends_at: [ 10, 0 ],
    color: "blue",
    location: "Home office",
    description: "Review deadlines, priorities, and upcoming appointments for the week."
  },
  {
    wday: 2,
    title: "Workout: strength training",
    starts: [ 7, 0 ],
    ends_at: [ 8, 0 ],
    color: "rose",
    location: "Neighborhood Gym",
    description: "Focused morning workout before the workday."
  },
  {
    wday: 3,
    title: "Dog training session",
    starts: [ 18, 0 ],
    ends_at: [ 19, 0 ],
    color: "lime",
    location: "Riverside Park",
    description: "Practice loose-leash walking, recall drills, and calm greetings."
  },
  {
    wday: 4,
    title: "Grocery pickup",
    starts: [ 16, 45 ],
    ends_at: [ 17, 15 ],
    color: "indigo",
    location: "Local Market",
    description: "Pick up the weekly grocery order before dinner."
  },
  {
    wday: 5,
    title: "Video call with parents",
    starts: [ 19, 0 ],
    ends_at: [ 19, 45 ],
    color: "emerald",
    location: "Home",
    description: "Catch up about the week and plan the next visit."
  },
  {
    wday: 6,
    title: "Weekly house cleaning",
    starts: [ 10, 0 ],
    ends_at: [ 11, 30 ],
    color: "emerald",
    location: "Home",
    description: "Recurring weekly household reset: laundry, floors, and kitchen cleanup."
  }
]

weekly_templates.each do |template|
  event_date = next_matching_date(seed_start, template[:wday])
  repeat_ends_on = seed_end
  occurrences_count = 1 + ((repeat_ends_on - event_date).to_i / 7)
  series = demo_user.event_series.create!(repeat_frequency: "weekly", repeat_ends_on: repeat_ends_on, occurrences_count: occurrences_count)

  create_event!(demo_user, **template.except(:wday), date: event_date, series: series)
end

monthly_templates = [
  {
    day: 1,
    title: "Submit rent payment",
    starts: [ 12, 0 ],
    ends_at: [ 12, 30 ],
    color: "amber",
    description: "Monthly bill reminder with a short time slot."
  },
  {
    day: 3,
    title: "Family budget check-in",
    starts: [ 9, 30 ],
    ends_at: [ 11, 0 ],
    color: "blue",
    location: "Kitchen table",
    description: "Review monthly expenses, savings goals, and upcoming household payments."
  },
  {
    day: 15,
    title: "Library book return",
    starts: [ 13, 15 ],
    ends_at: [ 13, 45 ],
    color: "slate",
    location: "Central Library",
    description: "Return borrowed books and pick up a reserved novel."
  },
  {
    day: 26,
    title: "Renew vehicle insurance",
    starts: [ 11, 0 ],
    ends_at: [ 11, 20 ],
    color: "amber",
    description: "Short reminder-style event near the end of the month."
  }
]

[ current_month, next_month ].each do |month|
  monthly_templates.each do |template|
    date = month + [ template[:day] - 1, month.end_of_month.day - 1 ].min.days
    create_event!(demo_user, **template.except(:day), date: date)
  end
end

relative_templates = [
  {
    offset: -2,
    title: "Past event: dinner with neighbors",
    starts: [ 18, 0 ],
    ends_at: [ 20, 0 ],
    color: "slate",
    location: "Maple Street Bistro",
    description: "A recent past event so previous days are populated during review."
  },
  {
    offset: 0,
    title: "Today: prepare dinner with friends",
    starts: [ 17, 0 ],
    ends_at: [ 19, 0 ],
    color: "blue",
    location: "Home",
    description: "Cook together before a relaxed evening at home."
  },
  {
    offset: 1,
    title: "Tomorrow: coffee with Sam",
    starts: [ 9, 0 ],
    ends_at: [ 10, 0 ],
    color: "cyan",
    location: "Corner Cafe",
    description: "Morning coffee and a casual catch-up."
  },
  {
    offset: 3,
    title: "Dentist appointment",
    starts: [ 8, 15 ],
    ends_at: [ 9, 0 ],
    color: "cyan",
    location: "Bright Smile Clinic",
    description: "Routine cleaning and check-up."
  },
  {
    offset: 8,
    title: "Annual health checkup",
    starts: [ 15, 0 ],
    ends_at: [ 16, 0 ],
    color: "white",
    location: "Family Medical Center",
    description: "Routine physical exam and updated blood work results."
  },
  {
    offset: 12,
    title: "Family birthday party",
    starts: [ 0, 0 ],
    ends_at: [ 23, 59 ],
    all_day: true,
    color: "rose",
    location: "Grandparents' house",
    description: "All-day family celebration with lunch, cake, and board games."
  },
  {
    offset: 17,
    title: "Weekend hiking trip",
    starts: [ 0, 0 ],
    ends_at: [ 23, 59 ],
    all_day: true,
    color: "orange",
    location: "Blue Ridge Trail",
    description: "All-day outdoor plan with packed lunch and an early start."
  },
  {
    offset: 24,
    title: "Interview preparation block",
    starts: [ 14, 0 ],
    ends_at: [ 16, 0 ],
    color: "violet",
    location: "Home office",
    description: "Practice project walkthroughs and refresh common Rails interview topics."
  },
  {
    offset: 36,
    title: "Neighborhood volunteer day",
    starts: [ 9, 30 ],
    ends_at: [ 12, 30 ],
    color: "orange",
    location: "Community Garden",
    description: "Weekend group cleanup and planting session."
  }
]

relative_templates.each do |template|
  date = today + template[:offset].days
  next unless date.between?(seed_start - 3.days, seed_end + 7.days)

  create_event!(demo_user, **template.except(:offset), date: date)
end

medication_series = demo_user.event_series.create!(repeat_frequency: "daily", repeat_ends_on: today + 9.days, occurrences_count: 10)
create_event!(
  demo_user,
  date: today,
  title: "Daily medication reminder",
  starts: [ 8, 0 ],
  ends_at: [ 8, 10 ],
  color: "violet",
  description: "Short recurring morning reminder.",
  series: medication_series
)

puts "Seeded demo account: example.user@example.com / examplepassword"
puts "Created #{demo_user.events.count} demo events across #{demo_user.event_series.count} recurring series."
puts "Demo calendar spans #{demo_user.events.minimum(:starts_at).to_date} through #{demo_user.events.maximum(:starts_at).to_date}."
