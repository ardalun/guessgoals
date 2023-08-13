import React from 'react';
import { Popover, Dropdown } from 'antd';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import styled, { css } from 'styled-components';
import Box from 'components/Box';
import Screen from 'lib/screen';
import BrandLogo from 'components/BrandLogo';
import Drawer from 'components/Drawer';
import LeaguesMenu from 'components/LeaguesMenu';
import TopMenuItem from './TopMenuItem';
import NotifBoard from './NotifBoard';
import { getBoardNotifs, markUnseensAsSeen } from 'redux/notif-board';

const TopMenuContainer = styled.div`
  display: flex;
  align-items: center;
  z-index: 2;
  
  ${Screen.max('lg')} {
    padding: 1rem 1rem 1rem 0;
    border-bottom: 1px solid #40474E;
    background: #1E262D;
    position: fixed;
    width: 100%;
    top: 0;
  }
`;

const RightMenu = styled.div`
  flex-grow: 1;
  display: inline-flex;
  justify-content: flex-end;
  align-items: center;
  font-size: 0.875rem;

  ${props => props.mobile && css`
    ${Screen.min('xs')} {
      display: none;
    }
  `}

  ${props => props.nonMobile && css`
    ${Screen.max('xs')} {
      display: none;
    }
  `}
`;

const LeftMenu = styled.div`
  display: inline-flex;
  align-items: center;

  ${Screen.min('lg')} {
    display: none;
  }
`;

const Divider = styled.div`
  border-right: 1px solid #40474E;
  height: 2rem;
  margin: 0.25rem 0;
`;

const DropdownItem = styled.div`
  height: 2.5rem;
  display: flex;
  width: 15rem;
  align-items: center;
  font-size: 1rem;
  padding: 0 1.5rem;
  color: #262F38;

  &:hover {
    background: rgba(0,0,0,0.1);
  }
`;

const DrawerMenuItemWrapper = styled.div`
  border-radius: 0.25rem;

  &:hover {
    background: rgba(0,0,0,0.1);
  }
`;

const DrawerMenuItem = styled.div`
  display: flex;
  width: 100%;
  padding: 1rem;
`;

const DrawerMenuItemBadge = styled.div`
  flex-grow: 1;
  display: flex;
  justify-content: flex-end;
  align-items: center;
`;

const DrawerBadge = styled.div`
  background: #F05A22;
  color: white;
  height: 1rem;
  border-radius: 10rem;
  font-size: 0.75rem;
  padding: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
`;

class TopMenu extends React.Component {
  constructor(props) {
    super(props);
    this.state = { 
      leaguesMenuDrawerOpened: false,
      MenuDrawerOpened: false,
      showNotifBoard: false
    };
  }

  openLeaguesMenuDrawer = () => {
    this.setState({
      leaguesMenuDrawerOpened: true,
    });
  };

  closeLeaguesMenuDrawer = () => {
    this.setState({
      leaguesMenuDrawerOpened: false,
    });
  };

  openMenuDrawer = () => {
    this.setState({
      menuDrawerOpened: true,
    });
  };

  closeMenuDrawer = () => {
    this.setState({
      menuDrawerOpened: false,
    });
  };

  toggleNotifBoard = showNotifBoard => {
    if (showNotifBoard) {
      this.props.getBoardNotifs()
        .then(() => {
          this.props.markUnseensAsSeen();
        });
    }
    this.setState({ showNotifBoard });
  };

  render() {
    return (
      <TopMenuContainer>
        { this.renderMenuDrawer() }
        { this.renderLeaguesMenuDrawer() }
        <LeftMenu>
          <TopMenuItem icon="im-menu" onClick={this.openLeaguesMenuDrawer} />
          <Divider />
          <Box ml={1}><BrandLogo smallerOnMobile /></Box>
        </LeftMenu>
        { this.renderNonMobileLoggedInMenu() }
        { this.renderMobileLoggedInMenu() }
        { this.renderLoggedOutMenu() }
      </TopMenuContainer>
    );
  }

  renderAccountMenu = () => {
    return (
      <div>
        <Box>
          <Link gray href="/my-bets">
            <DropdownItem>My Bets</DropdownItem>
          </Link>
        </Box>
        <Box>
          <Link gray href="/auth/logout" as="/logout">
            <DropdownItem>Logout</DropdownItem>
          </Link>
        </Box>
      </div>
    );
  }

  renderNonMobileLoggedInMenu = () => {
    const { showNotifBoard } = this.state;
    const { isLoggedIn, walletTotal, username, unseenNotifs } = this.props;
    if (!isLoggedIn) return null;

    return (
      <RightMenu nonMobile>
        <Popover 
          content={<NotifBoard />} 
          trigger="click"
          placement="bottomRight"
          visible={showNotifBoard}
          onVisibleChange={this.toggleNotifBoard}
        >
          <TopMenuItem icon="im-bell" iconSize={1.5} badge={unseenNotifs} />
        </Popover>
        <Divider />
        <Link href="/wallet" white>
          <TopMenuItem icon="im-bitcoin" iconSize={1.5} name={`${walletTotal} BTC`} />
        </Link>
        <Divider />
        <Popover content={this.renderAccountMenu()} trigger="click" placement="bottomRight">
          <TopMenuItem icon="im-user" pr={0} iconSize={1.3} name={username} />
        </Popover>
      </RightMenu>
    );
  }

  renderMobileLoggedInMenu = () => {
    const { isLoggedIn, username } = this.props;

    if (!isLoggedIn) return null;

    return (
      <RightMenu mobile>
        <TopMenuItem icon="im-user" iconSize={1.25} onClick={this.openMenuDrawer} name={username} />
      </RightMenu>
    );
  }

  renderLoggedOutMenu = () => {
    if (this.props.isLoggedIn) return null;

    return (
      <RightMenu>
        <Box mr={1}><Link white href="/auth/login" as="/login">Login</Link></Box>
        <Box><Link button href="/auth/signup" as="/signup">Sign up</Link></Box>
      </RightMenu>
    );
  }

  renderMenuDrawer = () => {
    const { walletTotal, unseenNotifs } = this.props;
    return (
      <Drawer
        placement="right"
        closable={true}
        width={300}
        onClose={this.closeMenuDrawer}
        visible={this.state.menuDrawerOpened}
      >
        <Box pt={2}>
          <DrawerMenuItemWrapper>
            <Link fluid href="/wallet" gray>
              <DrawerMenuItem>
                Wallet
                <DrawerMenuItemBadge>
                  {walletTotal} BTC
                </DrawerMenuItemBadge>
              </DrawerMenuItem>
            </Link>
          </DrawerMenuItemWrapper>
          <DrawerMenuItemWrapper>
            <Link fluid href="/my-bets" gray>
              <DrawerMenuItem>My Bets</DrawerMenuItem>
            </Link>
          </DrawerMenuItemWrapper>
          <DrawerMenuItemWrapper>
            <Link fluid href="/notifications" gray>
              <DrawerMenuItem>
                Notifications
                <DrawerMenuItemBadge>
                {
                  unseenNotifs > 0 && <DrawerBadge>{unseenNotifs}</DrawerBadge>
                }
                </DrawerMenuItemBadge>
              </DrawerMenuItem>
            </Link>
          </DrawerMenuItemWrapper>
          <DrawerMenuItemWrapper>
            <Link fluid href="/auth/logout" as="/logout" gray>
              <DrawerMenuItem>Log out</DrawerMenuItem>
            </Link>
          </DrawerMenuItemWrapper>
        </Box>
      </Drawer>
    );
  }

  renderLeaguesMenuDrawer = () => {
    return (
      <Drawer
        placement="left"
        closable={true}
        width={300}
        onClose={this.closeLeaguesMenuDrawer}
        visible={this.state.leaguesMenuDrawerOpened}
      >
        <LeaguesMenu onItemSelect={this.closeLeaguesMenuDrawer} />
      </Drawer>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  isLoggedIn:   !!deepRead(store, 'session.user'),
  walletTotal:  deepRead(store, 'session.user.wallet.total'),
  username:     deepRead(store, 'session.user.username'),
  unseenNotifs: deepRead(store, 'session.user.unseen_notifs')
});
const mapDispatchToProps = {
  getBoardNotifs,
  markUnseensAsSeen
};

export default connect(mapStateToProps, mapDispatchToProps)(TopMenu);