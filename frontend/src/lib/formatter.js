import { convertToTimeZone, formatToTimeZone } from 'date-fns-timezone';
import { format } from 'date-fns';

export const formatMatches = (matches, timezone, sortAsc = true) => {
  let matchesClone = [];
  matches.forEach(match => {
    let dateObj = convertToTimeZone(new Date(match.starts_at), {timeZone: timezone});
    let dateString = format(dateObj, 'ddd, MMM D');
    let shortDateString = format(dateObj, 'YYYY-MM-DD');
    let timeString = format(dateObj, 'h:mm A');
    matchesClone.push({ ...match, dateObj, dateString, timeString, shortDateString });
  })
  let matcheDates = {};
  const compareAsc = (a, b) => {
    if (a.dateObj < b.dateObj) return -1;
    else if (a.id < b.id) return -1;
    else return 1;
  };
  const compareDesc = (a, b) => {
    if (a.dateObj < b.dateObj) return 1;
    else if (a.id < b.id) return 1;
    else return -1;
  }
  let comparator = sortAsc ? compareAsc : compareDesc;
  matchesClone.sort(comparator).forEach(match => {
    if (match.dateString in matcheDates) {
      matcheDates[match.dateString].matches.push(match);
    } else {
      matcheDates[match.dateString] = {
        dateString: match.dateString,
        dateObj:    match.dateObj,
        matches:    [ match ]
      };
    }
  });
  return Object.values(matcheDates).sort(comparator);
}

export const formatScorers = (scorersHash) => {
  let result = [];
  Object.values(scorersHash).forEach(item => {
    for (let i = 0; i < item.goals; i++) {
      result.push({
        id: item.player.id,
        name: item.player.name
      })
    };
  });
  return result;
}

export const longTimeFormat = (dateTimeString, timezone) => {
  let dateObj = convertToTimeZone(new Date(dateTimeString), {timeZone: timezone});
  return formatToTimeZone(dateObj, 'YYYY-MM-DD h:mm A z',  {timeZone: timezone});
}