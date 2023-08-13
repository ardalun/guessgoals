import { Checkbox } from 'antd';
import styled, { css } from 'styled-components';

const StyledCheckbox = styled(Checkbox)`
  color: white;

  .ant-checkbox .ant-checkbox-inner {
    border: 2px solid #37424C;
    background: #1E262D;
  }
  .ant-checkbox-checked .ant-checkbox-inner {
    background: #FF7E00;
    border: 1px solid #FF7E00;
  }

  .ant-checkbox-wrapper:hover .ant-checkbox-inner,
  .ant-checkbox:hover .ant-checkbox-inner,
  .ant-checkbox-input:focus + .ant-checkbox-inner {
    border-color: #FF7E00;
  }
  .ant-checkbox-checked::after {
    border: 1px solid #FF7E00;
  }

  ${props => props.textGray && css`
    color: #858585;
  `}
`;

export default StyledCheckbox;
