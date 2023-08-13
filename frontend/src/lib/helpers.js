export const deepWrite = (obj, path, value) => {
  let nodes = path.split(/\.|\[/);
  let result = JSON.parse(JSON.stringify(obj));
  let lastRead = result;
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];
    if (i === nodes.length - 1) {
      if (node.endsWith(']')) {
        lastRead[parseInt(node.split(']')[0], 10)] = value;
      } else {
        lastRead[node] = value;
      }
    } else {
      let lastReadKey = null;
      if (node.endsWith(']')) {
        lastReadKey = parseInt(node.split(']')[0], 10);
      } else {
        lastReadKey = node;
      }    
      if (!lastRead[lastReadKey]) {
        lastRead[lastReadKey] = {}
      }
      lastRead = lastRead[lastReadKey];
    }
  }
  return result;
};

export const deepRead = (obj, path) => {
  let nodes = path.split(/\.|\[/);
  let lastRead = obj;
  for (let i = 0; i < nodes.length; i++) {
    if (lastRead === null) return null;
    let node = nodes[i];
    if (node.endsWith(']')) {
      lastRead = readValue(lastRead[parseInt(node.split(']')[0], 10)]);
    } else {
      lastRead = readValue(lastRead[node]);
    }
  }
  return lastRead;
};

export const changeTimezone = (date, toTimezone) => {
  let convertedDate = date.toLocaleString("en-US", {timeZone: toTimezone});
  return new Date(convertedDate);
}

function readValue(value) {
  if (typeof value === 'undefined') return null;
  return value;
}