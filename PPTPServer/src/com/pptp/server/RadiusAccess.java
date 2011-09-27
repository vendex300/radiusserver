package com.pptp.server;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RadiusAccess {
	public static boolean hasUser(Connection conn, String userName) {
		String sql = "SELECT * FROM radcheck WHERE username=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
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

	public static boolean addUser(Connection conn, String userName, String pwd) {
		String sql = "INSERT INTO radcheck SET username=?,attribute=?,op=?,value=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
			stmt.setString(2, "Cleartext-Password");
			stmt.setString(3, ":=");
			stmt.setString(4, pwd);
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

	public static boolean setGroup(Connection conn, String userName) {
		String sql = "INSERT INTO radusergroup SET username=?,groupname=?,priority=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
			stmt.setString(2, "vpnnb");
			stmt.setInt(3, 1);
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

	public static boolean removeFromGroup(Connection conn, String userName) {
		String sql = "DELETE FROM radcheck WHERE username=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
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

	public static boolean removeUser(Connection conn, String userName) {
		String sql = "DELETE FROM radusergroup WHERE username=?";
		PreparedStatement stmt = null;
		try {
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, userName);
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
