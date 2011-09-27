package com.pptp.server;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.pptp.bean.InviteCode;
import com.pptp.bean.Order;
import com.pptp.bean.User;

public class DBAccess {

	public static Connection getConn() {
		try {
			Class.forName("com.mysql.jdbc.Driver");
			return DriverManager.getConnection(
					"jdbc:mysql://192.168.1.202:3306/radius", "root",
					"20101010");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	public static void close(Connection conn) {
		try {
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static User getUserFromClientID(Connection conn, String clientID) {
		String sql = "SELECT tb_user.* FROM tb_user,tb_login_status WHERE tb_login_status.client_id=? AND tb_login_status.user_id=tb_user.id";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, clientID);
			ResultSet result = stmt.executeQuery();
			User user = null;
			if (result.next()) {
				int id = result.getInt("id");
				String email = result.getString("email");
				String name = result.getString("user_name");
				String pwd = result.getString("pwd");
				user = new User(id, email, name, pwd);
			}
			result.close();
			return user;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return null;
	}

	public static boolean hasEmail(Connection conn, String email) {
		String sql = "SELECT * FROM tb_user WHERE email=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, email);
			ResultSet rs = stmt.executeQuery();
			boolean b = rs.next();
			rs.close();
			return b;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

	public static boolean hasUser(Connection conn, String userName) {
		String sql = "SELECT * FROM tb_user WHERE user_name=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
			ResultSet rs = stmt.executeQuery();
			boolean b = rs.next();
			rs.close();
			return b;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

	public static boolean addLoginStatus(Connection conn, User user,
			String clientID, String deviceID, String date) {
		String sql = "INSERT INTO tb_login_status SET user_id=?,client_id=?,device_id=?,login_time=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, user.getId());
			stmt.setString(2, clientID);
			stmt.setString(3, deviceID);
			stmt.setString(4, date);
			return stmt.executeUpdate() > 0;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

	public static User getUser(Connection conn, String email) {
		String sql = "SELECT * FROM tb_user WHERE email=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, email);
			ResultSet result = stmt.executeQuery();
			if (result.next()) {
				int id = result.getInt(1);
				String name = result.getString("user_name");
				String pwd = result.getString("pwd");
				result.close();
				return new User(id, email, name, pwd);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return null;
	}

	public static User addUser(Connection conn, String email, String name,
			String pwd, String deviceID, String date) {
		String sql = "INSERT INTO tb_user SET email=?,device_id=?,reg_time=?,user_name=?,pwd=?";
		// String date = format.format(new Date());
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			stmt.setString(1, email);
			stmt.setString(2, deviceID);
			stmt.setString(3, date);
			stmt.setString(4, name);
			stmt.setString(5, pwd);
			stmt.executeUpdate();
			ResultSet result = stmt.getGeneratedKeys();
			if (result.next()) {
				int id = result.getInt(1);
				result.close();
				return new User(id, email, name, pwd);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

	public static boolean addNewOrder(Connection conn, Order order) {
		String sql = "INSERT INTO tb_new_order SET order_id=?,user_id=?,order_type=?,create_time=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			stmt.setString(1, order.getOrderID());
			stmt.setInt(2, order.getUserID());
			stmt.setInt(3, order.getOrderType());
			stmt.setString(4, order.getCreateTime());
			stmt.executeUpdate();
			ResultSet result = stmt.getGeneratedKeys();
			if (result.next()) {
				int id = result.getInt(1);
				order.setId(id);
				result.close();
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	public static boolean addCompleteOrder(Connection conn, Order order) {
		String sql = "INSERT INTO tb_complete_order SET order_id=?,user_id=?,order_type=?,create_time=?,complete_time=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			stmt.setString(1, order.getOrderID());
			stmt.setInt(2, order.getUserID());
			stmt.setInt(3, order.getOrderType());
			stmt.setString(4, order.getCreateTime());
			stmt.setString(5, order.getCompleteTime());
			stmt.executeUpdate();
			ResultSet result = stmt.getGeneratedKeys();
			if (result.next()) {
				int id = result.getInt(1);
				order.setId(id);
				result.close();
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	public static Order getNewOrder(Connection conn, String orderID) {
		String sql = "SELECT * FROM tb_new_order WHERE order_id=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, orderID);
			ResultSet result = stmt.executeQuery();
			if (result.next()) {
				int id = result.getInt("id");
				int userID = result.getInt("user_id");
				int orderType = result.getInt("order_type");
				String createTime = result.getString("create_time");
				result.close();
				return new Order(id, orderID, orderType, userID, createTime,
						null);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

	public static boolean removeNewOrder(Connection conn, String orderID) {
		String sql = "DELETE FROM tb_new_order WHERE order_id=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, orderID);
			return stmt.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	public static String getExpireTime(Connection conn, int userID) {
		String sql = "SELECT * FROM tb_expire WHERE user_id=? ORDER BY id DESC";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, userID);
			ResultSet result = stmt.executeQuery();
			if (result.next()) {
				String time = result.getString("expire_time");
				result.close();
				return time;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

	public static boolean addExpireTime(Connection conn, String time,
			Order order) {
		String sql = "INSERT INTO tb_expire SET user_id=?,expire_time=?,order_id=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, order.getUserID());
			stmt.setString(2, time);
			stmt.setString(3, order.getOrderID());
			return stmt.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		return false;
	}

	public static boolean addInviteCode(Connection conn, String[] code,
			int userID) {
		String sql = "INSERT INTO tb_invite_code SET user_id=?,code=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			for (String c : code) {
				stmt.setInt(1, userID);
				stmt.setString(2, c);
				stmt.addBatch();
			}
			conn.setAutoCommit(false);
			stmt.executeBatch();
			conn.setAutoCommit(true);
			stmt.close();
			return true;
		} catch (SQLException e) {
			try {
				conn.rollback();
			} catch (SQLException e1) {
			}
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

	public static InviteCode[] getInviteCode(Connection conn, int userID) {
		String sql = "SELECT * FROM tb_invite_code WHERE user_id=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, userID);
			ResultSet rs = stmt.executeQuery();
			rs.last();
			int row = rs.getRow();
			rs.first();
			InviteCode[] list = new InviteCode[row];
			int index = 0;
			while (rs.next()) {
				String code = rs.getString("code");
				int uu = rs.getInt("use_user_id");
				list[index] = new InviteCode(userID, code, uu);
			}
			rs.close();
			return list;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return null;
	}

	public static boolean isInviteCodeValidate(Connection conn, String code) {
		String sql = "SELECT * FROM tb_invite_code WHERE code=? AND use_user_id=0";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, code);
			ResultSet rs = stmt.executeQuery();
			boolean b = rs.next();
			rs.close();
			return b;
		} catch (SQLException e) {
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

	public static boolean useInviteCode(Connection conn, int userID, String code) {
		String sql = "UPDATE tb_invite_code SET use_user_id=? WHERE code=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, userID);
			stmt.setString(2, code);
			return stmt.executeUpdate() > 0;
		} catch (SQLException e) {
		} finally {
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException e) {
				}
			}
		}
		return false;
	}

}
