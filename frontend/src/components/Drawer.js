import { Drawer } from 'antd';

const MyDrawer = (props) => {
  return (
    <Drawer {...props}
      maskStyle={{opacity: '1', animation: 'none'}}
      bodyStyle={{ background: '#262F37', minHeight: '100vh', color: 'white' }}>
      {props.children}
    </Drawer>
  );
}

export default MyDrawer;