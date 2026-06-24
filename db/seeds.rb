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

today = Time.zone.today
month_start = today.beginning_of_month

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

events = [
  {
    date: month_start + 1.day,
    title: "Family budget check-in",
    starts: [ 9, 30 ],
    ends_at: [ 11, 0 ],
    color: "blue",
    location: "Kitchen table",
    description: "Review monthly expenses, savings goals, and upcoming household payments."
  },
  {
    date: month_start + 2.days,
    title: "Dog training session",
    starts: [ 18, 0 ],
    ends_at: [ 19, 0 ],
    color: "lime",
    location: "Riverside Park",
    description: "Practice loose-leash walking and recall drills."
  },
  {
    date: month_start + 4.days,
    title: "Dentist appointment",
    starts: [ 8, 15 ],
    ends_at: [ 9, 0 ],
    color: "cyan",
    location: "Bright Smile Clinic",
    description: "Routine cleaning and check-up."
  },
  {
    date: month_start + 5.days,
    title: "Submit rent payment",
    starts: [ 12, 0 ],
    ends_at: [ 12, 30 ],
    color: "amber",
    description: "Monthly bill reminder with a short time slot."
  },
  {
    date: month_start + 7.days,
    title: "Family birthday party",
    starts: [ 0, 0 ],
    ends_at: [ 23, 59 ],
    all_day: true,
    color: "rose",
    location: "Grandparents' house",
    description: "All-day family celebration with lunch, cake, and board games."
  },
  {
    date: month_start + 9.days,
    title: "Grocery pickup",
    starts: [ 16, 45 ],
    ends_at: [ 17, 15 ],
    color: "indigo",
    location: "Local Market",
    description: "Pick up the weekly grocery order before dinner."
  },
  {
    date: month_start + 12.days,
    title: "Video call with parents",
    starts: [ 19, 0 ],
    ends_at: [ 19, 45 ],
    color: "emerald",
    location: "Home",
    description: "Catch up about the week and plan the next visit."
  },
  {
    date: month_start + 14.days,
    title: "Workout: strength training",
    starts: [ 7, 0 ],
    ends_at: [ 8, 0 ],
    color: "rose",
    location: "Neighborhood Gym",
    description: "Lower-body workout before the workday."
  },
  {
    date: month_start + 16.days,
    title: "Library book return",
    starts: [ 13, 15 ],
    ends_at: [ 13, 45 ],
    color: "slate",
    location: "Central Library",
    description: "Return borrowed books and pick up a reserved novel."
  },
  {
    date: month_start + 18.days,
    title: "Weekend hiking trip",
    starts: [ 0, 0 ],
    ends_at: [ 23, 59 ],
    all_day: true,
    color: "orange",
    location: "Blue Ridge Trail",
    description: "All-day outdoor plan with packed lunch and an early start."
  },
  {
    date: month_start + 21.days,
    title: "Annual health checkup",
    starts: [ 15, 0 ],
    ends_at: [ 16, 0 ],
    color: "white",
    location: "Family Medical Center",
    description: "Routine physical exam and updated blood work results."
  },
  {
    date: month_start + 26.days,
    title: "Renew vehicle insurance",
    starts: [ 11, 0 ],
    ends_at: [ 11, 20 ],
    color: "amber",
    description: "Short reminder-style event near the end of the month."
  },
  {
    date: today - 2.days,
    title: "Past event: dinner with neighbors",
    starts: [ 14, 0 ],
    ends_at: [ 16, 0 ],
    color: "slate",
    location: "Maple Street Bistro",
    description: "A recent past event so previous days are populated during review."
  },
  {
    date: today,
    title: "Today: prepare dinner with friends",
    starts: [ 17, 0 ],
    ends_at: [ 19, 0 ],
    color: "blue",
    location: "Home",
    description: "Cook together before a relaxed evening at home."
  },
  {
    date: today + 1.day,
    title: "Tomorrow: coffee with Sam",
    starts: [ 9, 0 ],
    ends_at: [ 10, 0 ],
    color: "cyan",
    location: "Corner Cafe",
    description: "Morning coffee and a casual catch-up."
  }
]

events.each do |attributes|
  create_event!(demo_user, **attributes)
end

cleaning_series = demo_user.event_series.create!(repeat_frequency: "weekly", occurrences_count: 6)
6.times do |index|
  date = today.beginning_of_week(:monday) + index.weeks + 5.days
  create_event!(
    demo_user,
    date: date,
    title: "Weekly house cleaning",
    starts: [ 10, 0 ],
    ends_at: [ 11, 30 ],
    color: "emerald",
    location: "Home",
    description: "Recurring weekly household reset: laundry, floors, and kitchen cleanup.",
    series: cleaning_series
  )
end

medication_series = demo_user.event_series.create!(repeat_frequency: "daily", occurrences_count: 5)
5.times do |index|
  create_event!(
    demo_user,
    date: today + index.days,
    title: "Daily medication reminder",
    starts: [ 8, 0 ],
    ends_at: [ 8, 10 ],
    color: "violet",
    description: "Short recurring morning reminder.",
    series: medication_series
  )
end

puts "Seeded demo account: example.user@example.com / examplepassword"
puts "Created #{demo_user.events.count} demo events across #{demo_user.event_series.count} recurring series."
