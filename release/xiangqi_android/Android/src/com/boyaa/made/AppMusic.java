package com.boyaa.made;

import android.media.MediaPlayer;
import android.util.Log;

/**
 * 
 * This class is used for controlling background music
 * 
 */
public class AppMusic {

	private final static String TAG = "AppMusic";
	private float mLeftVolume;
	private float mRightVolume;
	private MediaPlayer mBackgroundMediaPlayer;
	private boolean mIsPaused;
	private String mCurrentPath;

	public AppMusic() {
		initData();
	}

	public void preloadBackgroundMusic(String path) {
		Release();
		createMediaplayerFromFile(path);
	}

	public void playBackgroundMusic(String path, boolean isLoop) {
		if (path == null) {
			return;
		}
		if (!path.equals(mCurrentPath)) {
			Release();
			createMediaplayerFromFile(path);
		}
		if (mBackgroundMediaPlayer != null) {
			try {
				mBackgroundMediaPlayer.setLooping(isLoop);
				if (!mIsPaused) {
					mBackgroundMediaPlayer.seekTo(0);
				}
				mBackgroundMediaPlayer.start();
				mIsPaused = false;
			} catch (IllegalStateException e) {
				e.printStackTrace();
			}
		}
	}

	public void stopBackgroundMusic() {
		Release();
	}

	public void pauseBackgroundMusic() {
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.pause();
			mIsPaused = true;
		}
	}

	public void resumeBackgroundMusic() {
		if (mIsPaused && mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.start();
			mIsPaused = false;
		}
	}

	public void rewindBackgroundMusic() {
		if (mBackgroundMediaPlayer != null) {
			try {
				mBackgroundMediaPlayer.seekTo(0);
				mBackgroundMediaPlayer.start();
				mIsPaused = false;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public boolean isBackgroundMusicPlaying() {
		return mBackgroundMediaPlayer != null
				&& mBackgroundMediaPlayer.isPlaying();
	}

	public void end() {
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.release();
		}
		mBackgroundMediaPlayer = null;
		mIsPaused = false;
		mCurrentPath = null;
	}

	public void Release() {
		end();
	}

	public float getBackgroundVolume() {
		if (mBackgroundMediaPlayer != null) {
			return (mLeftVolume + mRightVolume) / 2f;
		}
		return 0;
	}

	public void setBackgroundVolume(float volume) {
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.setVolume(volume, volume);
		}
		mLeftVolume = volume;
		mRightVolume = volume;
	}

	private void initData() {
		mLeftVolume = 0.5f;
		mRightVolume = 0.5f;
		mBackgroundMediaPlayer = null;
		mIsPaused = false;
		mCurrentPath = null;
	}

	private void createMediaplayerFromFile(String path) {
		Release();
		mBackgroundMediaPlayer = new MediaPlayer();
		try {
			mBackgroundMediaPlayer.setDataSource(path);
			mBackgroundMediaPlayer.setVolume(mLeftVolume, mRightVolume);
			mBackgroundMediaPlayer.prepare();
		} catch (Exception e) {
			e.printStackTrace();
		}
		mCurrentPath = path;
		mIsPaused = false;
	}
}
