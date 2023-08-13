import { notification } from 'antd';
import Heading from 'components/Heading';
import Box from 'components/Box';
import { Fragment } from 'react';

export const notifyError = (title, message, duration = 3) => {
  let description = message;
  if (typeof message !== 'string') {
    description = (
      <Fragment>
        {
          message.map((item, index) => {
            return (
              <Box key={`message_part_${index}`} mb={0.5} body2>
                {item}
              </Box>
            );
          })
        }
      </Fragment>
    );
  }
  const args = {
    message: <Heading as="span" sizeLike="h2">{title}</Heading>,
    description: description,
    duration: duration,
    className: 'gg-notification-error'
  };
  notification.open(args);
};

export const notifySuccess = (title, message, duration = 3) => {
  let description = message;
  if (typeof message !== 'string') {
    description = (
      <Fragment>
        {
          message.map((item, index) => {
            return (
              <Box key={`message_part_${index}`} mb={0.5} body2>
                {item}
              </Box>
            );
          })
        }
      </Fragment>
    );
  }
  const args = {
    message: <Heading as="span" sizeLike="h2">{title}</Heading>,
    description: description,
    duration: duration,
    className: 'gg-notification-success'
  };
  notification.open(args);
};

export const notifyComponent = (component, duration = 3) => {
  const args = {
    message: null,
    description: component,
    duration: duration
  };
  notification.open(args);
};