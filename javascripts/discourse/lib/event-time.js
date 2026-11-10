import { i18n } from "discourse-i18n";

const DATE_ONLY = /^\d{4}-\d{2}-\d{2}$/;

function locale() {
  return i18n.currentBcp47Locale || undefined;
}

export function startOfDay(date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function endOfDay(date) {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    23,
    59,
    59,
    999
  );
}

// All-day events arrive as `YYYY-MM-DD`; parsing those with `new Date()` would
// treat them as UTC and shift the day in western timezones.
export function parseEventDate(value, allDay = false) {
  if (!value) {
    return null;
  }

  if (allDay || DATE_ONLY.test(value)) {
    const [year, month, day] = value.slice(0, 10).split("-").map(Number);
    return new Date(year, month - 1, day);
  }

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function formatEventMonth(date) {
  return new Intl.DateTimeFormat(locale(), { month: "short" }).format(date);
}

export function formatEventDay(date) {
  return new Intl.DateTimeFormat(locale(), { day: "numeric" }).format(date);
}

export function formatEventTime(date) {
  return new Intl.DateTimeFormat(locale(), {
    hour: "numeric",
    minute: "2-digit",
  }).format(date);
}
